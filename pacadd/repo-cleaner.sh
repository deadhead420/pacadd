#!/bin/bash

repo_dir=/srv/ftp/dh-repo/
count=1
removed_count=0
pkg=$(cat pkg.list | awk "NR==$count")
while [ -n "$pkg" ]
	do
	num=$(ls "$repo_dir" | grep -G "^$pkg" | wc -l)
	if [ "$num" -gt "1" ]; then
		false_list=$(cat pkg.list | sed "0,/$pkg/s///" | grep -G "^$pkg" | sed 's/^/\^/g')
		if [ -n "$false_list" ]; then
			false_dupes=$(ls "$repo_dir" | egrep "$false_list" | wc -w)
			if [ "$false_dupes" -gt "0" ]; then
				if [[ "$false_dupes" -eq "1" && "$num" -eq "3" ]]; then
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==1')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")	
				elif [[ "$false_dupes" -eq "1" && "$num" -eq "4" ]]; then
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==1')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==2')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
				elif [[ "$false_dupes" -eq "2" && "$num" -eq "4" ]]; then
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==1')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
				elif [[ "$false_dupes" -eq "1" && "$num" -eq "5" ]]; then
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==1')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==2')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==3')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
				elif [[ "$false_dupes" -eq "2" && "$num" -eq "5" ]]; then
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==1')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==2')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
				elif [[ "$false_dupes" -eq "3" && "$num" -eq "5" ]]; then
					out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==1')
					rm "$repo_dir"/"$out_of_date"
					echo "$out_of_date" >> removed_packages.list
					removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
				fi
			else
				out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==1')
				rm "$repo_dir"/"$out_of_date"
				echo "$out_of_date" >> removed_packages.list
				removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
			fi
		else
			out_of_date=$(ls "$repo_dir" | grep -G "^$pkg" | awk 'NR==1')
			rm "$repo_dir"/"$out_of_date"
			echo "$out_of_date" >> removed_packages.list
			removed_count=$(awk "BEGIN {print $removed_count+1; exit}")
		fi
	fi
	count=$(awk "BEGIN {print $count+1; exit}")
	pkg=$(cat pkg.list | awk "NR==$count")
done
echo "Removed package count was: $removed_count"
echo 
echo "The following outdated packages were removed from the repository"
echo
tail -n"$removed_count" removed_packages.list
