#!/bin/bash

#colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
rest='\033[0m'

case "$(uname -m)" in
x86_64 | x64 | amd64)
	cpu=amd64
	;;
i386 | i686)
	cpu=386
	;;
armv8 | armv8l | arm64 | aarch64)
	cpu=arm64
	;;
armv7l)
	cpu=arm
	;;
*)
	echo "The current architecture is $(uname -m), not supported"
	exit
	;;
esac

cfwarpIP() {
	if [[ ! -f "$PREFIX/bin/warpendpoint" ]]; then
		echo "Downloading warpendpoint program"
		if [[ -n $cpu ]]; then
			curl -L -o warpendpoint -# --retry 2 https://raw.githubusercontent.com/Ptechgithub/warp/main/endip/$cpu
			cp warpendpoint $PREFIX/bin
			chmod +x $PREFIX/bin/warpendpoint
		fi
	fi
}

endipv6() {
	n=0
	iplist=100
	
	# IPv6 CIDR ranges for Cloudflare WARP
	cidrs=(
		"2606:4700:d0::/48"
		"2606:4700:d1::/48"
	)
	
	while [ $n -lt $iplist ]; do
		# Select random CIDR
		cidr=${cidrs[$((RANDOM % ${#cidrs[@]}))]}
		
		# Extract base prefix and prefix length
		base_prefix=$(echo $cidr | cut -d'/' -f1)
		prefix_length=$(echo $cidr | cut -d'/' -f2)
		
		# Generate random suffix for the remaining bits
		# For /48 networks, we have 80 bits remaining (128-48=80)
		remaining_bits=$((128 - prefix_length))
		hex_groups=$((remaining_bits / 16))
		
		# Generate random hex values for each remaining 16-bit group
		suffix=""
		for ((i=0; i<hex_groups; i++)); do
			if [ $i -eq 0 ]; then
				suffix=$(printf '%x' $((RANDOM * RANDOM % 65536)))
			else
				suffix="${suffix}:$(printf '%x' $((RANDOM * RANDOM % 65536)))"
			fi
		done
		
		# Construct the full IPv6 address
		if [[ $base_prefix == *"::" ]]; then
			# If base ends with ::, append suffix directly
			ipv6="${base_prefix}${suffix}"
		else
			# Otherwise add :: separator
			ipv6="${base_prefix}::${suffix}"
		fi
		
		# Add brackets and port
		temp[$n]="[${ipv6}]:2408"
		n=$(($n + 1))
	done
	
	# Remove duplicates and ensure we have exactly iplist unique IPs
	unique_ips=($(printf '%s\n' "${temp[@]}" | sort -u))
	while [ ${#unique_ips[@]} -lt $iplist ]; do
		# Generate more IPs if we don't have enough unique ones
		cidr=${cidrs[$((RANDOM % ${#cidrs[@]}))]}
		base_prefix=$(echo $cidr | cut -d'/' -f1)
		prefix_length=$(echo $cidr | cut -d'/' -f2)
		remaining_bits=$((128 - prefix_length))
		hex_groups=$((remaining_bits / 16))
		
		suffix=""
		for ((i=0; i<hex_groups; i++)); do
			if [ $i -eq 0 ]; then
				suffix=$(printf '%x' $((RANDOM * RANDOM % 65536)))
			else
				suffix="${suffix}:$(printf '%x' $((RANDOM * RANDOM % 65536)))"
			fi
		done
		
		if [[ $base_prefix == *"::" ]]; then
			ipv6="${base_prefix}${suffix}"
		else
			ipv6="${base_prefix}::${suffix}"
		fi
		
		new_ip="[${ipv6}]:2408"
		
		# Check if this IP is already in our list
		duplicate=false
		for existing_ip in "${unique_ips[@]}"; do
			if [ "$existing_ip" = "$new_ip" ]; then
				duplicate=true
				break
			fi
		done
		
		if [ "$duplicate" = false ]; then
			unique_ips+=("$new_ip")
		fi
	done
	
	# Copy back to temp array
	for ((i=0; i<iplist; i++)); do
		temp[$i]="${unique_ips[$i]}"
	done
}

endipresult() {
	echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u >ip.txt
	ulimit -n 102400
	chmod +x warpendpoint >/dev/null 2>&1
	if command -v warpendpoint &>/dev/null; then
		warpendpoint
	else
		./warpendpoint
	fi

	clear
	cat result.csv | awk -F, '$3!="timeout ms" {print} ' | sort -t, -nk2 -nk3 | uniq | head -11 | awk -F, '{print "Endpoint "$1" Packet Loss Rate "$2" Average Delay "$3}'
	Endip_v6=$(cat result.csv | grep -oE "\[.*\]:[0-9]+" | head -n 1)
	delay=$(cat result.csv | grep -oE "[0-9]+ ms|timeout" | head -n 1)
	echo ""
	echo -e "${green}Results Saved in result.csv${rest}"
	echo ""
	if [ "$Endip_v6" ]; then
		echo -e "${purple}********************************************${rest}"
		echo -e "${purple}*          ${yellow}Best [IPv6]:Port                ${purple}*${rest}"
		echo -e "${purple}*                                          *${rest}"
		echo -e "${purple}* ${cyan}$Endip_v6${purple} *${rest}"
		echo -e "${purple}*           ${cyan}Delay: ${green}[$delay]               ${purple}*${rest}"
		echo -e "${purple}********************************************${rest}"
	else
		echo -e "${red} No valid IP addresses found.${rest}"
	fi
	rm warpendpoint >/dev/null 2>&1
	rm -rf ip.txt
	exit
}

#Menu
clear
echo -e "${cyan}By --> Peyman * Github.com/Ptechgithub * ${rest}"
echo ""
echo -e "${purple}**********************${rest}"
echo -e "${purple}*  ${green}IPv6 Scanner     ${purple} *${rest}"
echo -e "${purple}**********************${rest}"
echo -e "${purple}[1] ${cyan}Scan ${green}IPv6${purple}       * ${rest}"
echo -e "${purple}                     *${rest}"
echo -e "${purple}[${red}0${purple}] Exit             *${rest}"
echo -e "${purple}**********************${rest}"
echo -en "${cyan}Enter your choice: ${rest}"
read -r choice
case "$choice" in
1)
	echo -e "${purple}*********************${rest}"
	cfwarpIP
	endipv6
	endipresult
	;;
0)
	echo -e "${purple}*********************${rest}"
	echo -e "${cyan}Goodbye!${rest}"
	exit
	;;
*)
	echo -e "${yellow}********************${rest}"
	echo "Invalid choice. Please select a valid option."
	;;
esac
