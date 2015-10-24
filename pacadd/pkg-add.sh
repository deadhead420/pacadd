#!/bin/bash

# define enviornment variables here
config=$(cat /etc/pkg-add.conf)
export Repo_Name=$(echo "$config" | grep "Repo_Name =" | awk '{print $3}')
export Repo_Dir=$(echo "$config" | grep "Repo_Dir =" | awk '{print $3}')
export Remote_Repo=$(echo "$config" | grep "Remote_Repo =" | awk '{print $3}')								
export Repo_Server=$(echo "$config" | grep "Repo_Server =" | awk '{print $3}')
export parm="$*"
export arch=$(uname -a | grep -o "x86_64\|i386\|i686")
if [ "$arch" == "i386" ]; then
	export arch=i686
fi

Init() {
case "$*" in
	[-Su]* | [--aur]*) User_Repo ;;
	[-S]* | [--sync]*) Offical_Repo ;;
#	[-Syu]*) Update_Repos ;;
	*) Search ;;
esac
}

User_Repo() {
full_query=$(echo "$parm" | tr " " "\n")
int=2
add_query=$(echo "$full_query" | awk "NR==$int")
if [[ -n "$Repo_Dir" && "$Repo_name" ]]; then
	while [ -n "$add_query" ]
		do
			wget -q --spider https://aur4.archlinux.org/cgit/aur.git/snapshot/"$add_query".tar.gz
			if [ "$?" -eq "0" ]; then
				if [[ "$Remote_Repo" == "true" && -n "$Repo_Server" ]]; then
					ssh -t $Repo_Server "wget https://aur4.archlinux.org/cgit/aur.git/snapshot/"$add_query".tar.gz -O "$Repo_Dir"/aur-pkg/"$add_query".tar.gz && \
								    	 cd "$Repo_Dir"/aur-pkg && tar -xf "$query".tar.gz && cd "$add_query" && makepkg -s && mv "$add_query"*.pkg.tar.xz ../../ && \
								    	 repo-add -R "$Repo_Dir"/"$Repo_Name".db.tar.gz "$Repo_Dir"/"$add_query"*pkg.tar.xz"
					if [ "$?" -gt "0" ]; then
						echo "Error encountered, cleaning up..."
						ssh -t $Repo_Server "rm -r "$Repo_Dir"/aur-pkg/"$add_query".tar.gz "$Repo_Dir"/aur-pkg/"$add_query""
						add_query=""
					fi
				else
					wget https://aur4.archlinux.org/cgit/aur.git/snapshot/"$add_query".tar.gz -O "$Repo_Dir"/aur-pkg/"$add_query".tar.gz
					cd "$Repo_Dir"/aur-pkg && tar -xf "$add_query".tar.gz && cd "$add_query" && makepkg -s
					if [ "$?" -gt "0" ]; then
						echo "Error encountered, cleaning up..."
						rm -r "$Repo_Dir"/aur-pkg/"$add_query".tar.gz "$Repo_Dir"/aur-pkg/"$add_query"
						add_query=""
					else
						mv "$add_query"*.pkg.tar.xz ../../
						repo-add -R "$Repo_Dir"/"$Repo_Name".db.tar.gz "$Repo_Dir"/"$add_query"*pkg.tar.xz
					fi
				fi
				query="$query $add_query"
				int=$(awk "BEGIN {print $int+1; exit}")
				add_query=$(echo "$*" | tr " " "\n" | awk "NR==$int")
			else
				echo "ERROR package $query not found"
				echo "continuing..."
				int=$(awk "BEGIN {print $int+1; exit}")
				add_query=$(echo "$full_query" | awk "NR==$int")
			fi
		  done
	if [[ "$Remote_Repo" == "true" && -n "$Repo_Server" ]]; then
		added_depends=$(ssh -t $Repo_Server "pacman -Qn | grep -vwf "$Repo_Dir"/package.list" | awk '{print $1}')
		if [ -n "$added_depends" ]; then													
			ssh -t $Repo_Server "echo '$added_depends' >> '$Repo_Dir'/package.list"
			int=1
			add_pkg=$(echo "$added_depends" | awk "NR==$int")
			while [ -n "$add_pkg" ]
				do
					ssh -t $Repo_Server "cp /var/cache/pacman/pkg/"$add_pkg"*.pkg.tar.xz "$Repo_Dir""
					ssh -t $Repo_Server "repo-add -R "$Repo_Dir"/"$Repo_Name".db.tar.gz "$Repo_Dir"/"$add_pkg"*pkg.tar.xz"
					int=$(awk "BEGIN {print $int+1; exit}")
					add_pkg=$(echo "$added_depends" | awk "NR==$int")
				done
		fi
	else
		added_depends=$(ssh -t $Repo_Server "pacman -Qn | grep -vwf "$Repo_Dir"/package.list" | awk '{print $1}')						
		if [ -n "$added_depends" ]; then													
			echo "$added_depends" >> "$Repo_Dir"/package.list							
			int=1
			add_pkg=$(echo "$added_depends" | awk "NR==$int")
			while [ -n "$add_pkg" ]													
				do
					cp /var/cache/pacman/pkg/"$add_pkg"*.pkg.tar.xz "$Repo_Dir"
					repo-add -R "$Repo_Dir"/"$Repo_Name".db.tar.gz "$Repo_Dir"/"$add_pkg"*pkg.tar.xz
					int=$(awk "BEGIN {print $int+1; exit}")
					add_pkg=$(echo "$added_depends" | awk "NR==$int")
				done
		fi
	fi
sudo pacman -Syyy
sudo pacman -S "$query"
else
int=2
query=$(echo "$full_query" | awk "NR==$int")
	while [ -n "$query" ]
		do
			wget -q --spider https://aur4.archlinux.org/cgit/aur.git/snapshot/"$query".tar.gz
			if [ "$?" -eq "0" ]; then
				wget https://aur4.archlinux.org/cgit/aur.git/snapshot/"$query".tar.gz -O /tmp/"$query".tar.gz
				cd /tmp && tar -xf "$query".tar.gz && cd "$query" && makepkg -si && cd .. && rm -r "$qurey" "$query".tar.gz
			else
				echo "ERROR package $query not found, continuing..."
			fi
			int=$(awk "BEGIN {print $int+1; exit}")
			query=$(echo "$full_query" | awk "NR==$num")
		done
fi
}

Offical_Repo() {
if [ -z "$query" ]; then
query=$(echo "$parm" | cut -d' ' -f2-)
fi
if [[ -n "$Repo_Dir" && "$Repo_name" ]]; then
	sudo pacman -Sy
	pkg_check=$(pacman -S --print-format='%n %l' "$query" | grep "http://")
	if [ "$?" -eq "0" ]; then
		query=""
		int=1
		pkg_name=$(echo "$pkg_check" | awk 'NR=='$int'  {print $1}')
		while [ -n "$pkg_name" ]
			do
				pkg_url=$(echo "$pkg_check" | awk 'NR=='$int'  {print $2}')
				pkg_update=$(echo "$pkg_url" | sed -n -e 's!^.*'$arch'/!!p')
				if [[ "$Remote_Repo" == "true" && -n "$Repo_Server" ]]; then
					ssh $Repo_Server "echo "$pkg_name" >> "$Repo_Dir"/package.list && \ 
									  wget "$pkg_url" -O "$Repo_Dir"/"$pkg_update" && \
									  repo-add -R "$Repo_Dir"/"$Repo_Name".db.tar.gz "$Repo_Dir"/"$pkg_update" && \
									  echo "$pkg_update" >> "$Repo_Dir"/updated_packages.list"
					if [ "$?" -eq "0" ]; then
						echo "Package $pkg_name added to custom repository"
					else
						echo "Error encountered, continuing..."
						pkg_name=""
					fi
				else
					echo "$pkg_name" >> "$Repo_Dir"/package.list
					wget "$pkg_url" -O "$Repo_Dir"/"$pkg_update"
					repo-add -R "$Repo_Dir"/"$Repo_Name".db.tar.gz "$Repo_Dir"/"$pkg_update"
					echo "$pkg_update" >> "$Repo_Dir"/updated_packages.list
				fi
				query="$query $pkg_name"
				int=$(awk "BEGIN {print $int+1; exit}")
				pkg_name=$(echo "$pkg_check" | awk 'NR=='$count'  {print $1}')
			done
		sudo pacman -Syyy
	fi
	sudo pacman -S "$query"
else
	sudo pacman -S "$query"
fi
}

Search() {
search=$(pacman -Ss "$parm")
if [ "$?" -eq "0" ]; then
	line_count=$(echo "$search" | wc -l)
	package_count=$(awk "BEGIN {print $line_count/2; exit}")
	package_int=1
	label_int=1
	until [ "$package_int" -gt "$package_count" ]
		do
			if [ "$package_int" -eq "1" ]; then
				result=$(echo "$search" | sed "$label_int i$package_int)---------------")
				label_int=$(awk "BEGIN {print $label_int+3; exit}")
				package_int=$(awk "BEGIN {print $package_int+1; exit}")
			else
				result=$(echo "$result" | sed "$label_int i $package_int)---------------")
				label_int=$(awk "BEGIN {print $label_int+3; exit}")
				package_int=$(awk "BEGIN {print $package_int+1; exit}")
			fi
		done
	echo "$result"
	echo -n "Select the number(s) of the package(s) you would like to add: [1,2,3...] "
	read input
	selected=$(echo "input" | tr " " "\n" | awk 'NR==1')
	int=1
	while [ -n "$selected" ]
		do
			if [ "$int" -eq "1" ]; then
				add_query=$(echo "$result" | awk "NR==2" | sed -n -e 's!^.*/!!p' | awk '{print $1}')
			else
				add_query=$(echo "$result" | sed -ne '/^'$selected')---------------$/{s///; :a' -e 'n;p;ba' -e '}' | awk "NR==1"  | sed -n -e 's!^.*/!!p' | awk '{print $1}')
			fi
			query="$query $add_query"
			int=$(awk "BEGIN {print $int+1; exit}")
			selected=$(echo "input" | tr " " "\n" | awk "NR==$int")
		done
	if [ -n "$query" ]; then	
		query=$(echo "$query" | sed 's/^ //')
		Offical_Repo
	else
		echo "Error selecting packages. Quitting"
		exit 1
	fi
else
	echo "ERROR package $pkg not found"
	exit 1
fi
}
Init
