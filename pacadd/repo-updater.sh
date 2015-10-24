#!/bin/bash

# Define the repository name here
repo_name=dh-repo

# Define the repository directory here
repo_dir=/srv/ftp/dh-repo

if [ -f "pacman.conf.orig" ]; then
	:
else
	wget "http://www.lateo.net/dl/divers/pacman.conf" -O pacman.conf.orig				# fetch original config if it does not exist.
	arch=$(uname -a | grep -o "x86_64\|i386\|i686")										# check kernel architecture
	if [ "$arch" == "x86_64" ]; then													# if kernel is 64 bit add multilib repos
		sed -i '/\[multilib]$/ {
		N
		/Include/s/#//g}' pacman.conf.orig
	fi
fi
repo_dir_listing=$(ls "$repo_dir")														# list current contents of repo directory
pacman --config=pacman.conf.orig -Sp $(< package.list) | sed -e '1,8d' | grep -v "$repo_dir_listing" > url.list		# saves url's for packages defined in package.list which do not already exist
count=1																					# sets count for loop
url=$(cat "url.list" | awk "NR==$count")												# selects first url 
while [ -n "$url" ]
	do
		pkg=$(echo "$url" | sed -n -e 's!^.*x86_64/!!p')								# defines only package name, version, and extensions
		wget "$url" -O "$repo_dir"/"$pkg"												# wget url's in order, save in repo directory as package-name.pkg.tar.xz
		echo "$pkg" >> updated_packages.list											# echo name of update package into a list
		count=$(awk "BEGIN {print $count+1; exit}")										# increase loop count by 1
		url=$(cat "url.list" | awk "NR==$count")										# check for next url and continue back at defining package name if found
	done
count=$(awk "BEGIN {print $count-1; exit}")												# correct count by one for original definition
updated_packages=$(tail -n"$count" updated_packages.list | sed "s|^|$repo_dir/|g")		# list updated packages with full path
add_count=1																				# sets count for a second loop
add_package=$(echo "$updated_packages" | awk "NR==$add_count")							# selects first updated package
while [ -n "$add_package" ]																# continues checking list of updated packages
	do
		repo-add -R "$repo_dir"/"$repo_name".db.tar.gz "$add_package"					# adds new packages to the repo
		add_count=$(awk "BEGIN {print $add_count+1; exit}")								# increase loop count by 1 
		add_package=$(echo "$updated_packages" | awk "NR==$add_count")					# checks for next package if found continue back at adding to repo
	done
updated_packages=$(tail -n"$count" updated_packages.list)
echo
echo "Update complete"
echo
echo "Updated packages:"
echo
echo "$updated_packages"
echo
echo "$count New packages added to the repository"
