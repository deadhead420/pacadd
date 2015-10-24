#!/bin/bash
read -r -p "Generate an alternate pacman.conf for this repository? [y/N] " response
case $response in
    [yY][eE][sS]|[yY][""])
		cp /etc/pacman.conf "$repo_name".pacman.conf
		read -r -p "Create using local ip? Yes if using repository with ftp server. [y/N] " response
			case $response in
				[yY][eE][sS]|[yY][""])
					local_ip=$(ip addr | grep -w "scope global" | awk '{print $2}' | sed -n -e 's!/.*!/!p')
					server="ftp://'$local_ip'/'$repo_name'"
				;;
				*)
					server="file://'$repo_dir'"
				;;
			esac
		sed -i "/core/i \
		[$repo_name] \
		Server = $server \
		SigLevel = Never \
		" "$repo_name".pacman.conf
    ;;
    *)
		:	
	;;
esac