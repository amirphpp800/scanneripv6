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
"2001:720::/29"
"2001:a50::/32"
"2001:ac0::/29"
"2001:b90::/32"
"2001:ba0::/32"
"2001:1498::/32"
"2001:1a58::/32"
"2001:31c0::/29"
"2001:4030::/32"
"2001:40b0::/32"
"2001:4108::/32"
"2001:4c60::/32"
"2001:4d10::/32"
"2a00:d60::/32"
"2a00:e70::/32"
"2a00:1508::/32"
"2a00:1660::/32"
"2a00:1af0::/29"
"2a00:1d70::/29"
"2a00:4560::/32"
"2a00:4920::/29"
"2a00:4b80::/32"
"2a00:4f20::/32"
"2a00:4fe0::/29"
"2a00:5ac0::/32"
"2a00:5c00::/32"
"2a00:6640::/29"
"2a00:6860::/29"
"2a00:6940::/32"
"2a00:69e0::/32"
"2a00:6ac0::/32"
"2a00:6da0::/32"
"2a00:7100::/32"
"2a00:7120::/32"
"2a00:71c0::/32"
"2a00:73c0::/32"
"2a00:7720::/32"
"2a00:7b00::/29"
"2a00:7e60::/32"
"2a00:7f00::/32"
"2a00:83e0::/32"
"2a00:84e0::/32"
"2a00:8a80::/29"
"2a00:8cc0::/32"
"2a00:8e20::/32"
"2a00:91a0::/32"
"2a00:93c0::/32"
"2a00:9440::/32"
"2a00:99c0::/32"
"2a00:9a20::/32"
"2a00:9a60::/32"
"2a00:9ac0::/32"
"2a00:a220::/32"
"2a00:a340::/32"
"2a00:a3a0::/32"
"2a00:a620::/32"
"2a00:a6c0::/32"
"2a00:a840::/32"
"2a00:ac20::/32"
"2a00:b080::/32"
"2a00:b5c0::/32"
"2a00:b8e0::/32"
"2a00:bc40::/29"
"2a00:be60::/29"
"2a00:bec0::/29"
"2a00:bf80::/32"
"2a00:c140::/32"
"2a00:c180::/29"
"2a00:c420::/32"
"2a00:c840::/32"
"2a00:ce00::/32"
"2a00:cea0::/32"
"2a00:d080::/32"
"2a00:d100::/29"
"2a00:d280::/32"
"2a00:d9e0::/32"
"2a00:db40::/32"
"2a00:dbe0::/32"
"2a00:dc80::/29"
"2a00:dd60::/32"
"2a00:e160::/32"
"2a00:e1e0::/32"
"2a00:e9c0::/32"
"2a00:eda0::/32"
"2a00:f380::/32"
"2a00:f640::/29"
"2a00:f800::/32"
"2a00:fdc0::/32"
"2a00:fde0::/32"
"2a00:fe40::/32"
"2a01:48::/32"
"2a01:f0::/32"
"2a01:1a0::/29"
"2a01:1c8::/29"
"2a01:250::/32"
"2a01:770::/32"
"2a01:4100::/32"
"2a01:4140::/32"
"2a01:4480::/32"
"2a01:48e0::/32"
"2a01:4a80::/32"
"2a01:4b80::/32"
"2a01:4e40::/32"
"2a01:5280::/32"
"2a01:54a0::/32"
"2a01:5780::/32"
"2a01:57a0::/32"
"2a01:5b20::/32"
"2a01:5fe0::/32"
"2a01:6040::/32"
"2a01:6840::/32"
"2a01:68a0::/32"
"2a01:6900::/32"
"2a01:6fa0::/32"
"2a01:71c0::/31"
"2a01:72e0::/32"
"2a01:7560::/32"
"2a01:7580::/32"
"2a01:7680::/32"
"2a01:7880::/32"
"2a01:7d00::/32"
"2a01:8460::/32"
"2a01:8480::/29"
"2a01:86c0::/32"
"2a01:88a0::/32"
"2a01:8da0::/32"
"2a01:9140::/32"
"2a01:91e0::/32"
"2a01:92a0::/32"
"2a01:9340::/32"
"2a01:98e0::/29"
"2a01:9f20::/32"
"2a01:a260::/32"
"2a01:a360::/32"
"2a01:a4c0::/32"
"2a01:a8a0::/32"
"2a01:a940::/29"
"2a01:aba0::/32"
"2a01:ace0::/32"
"2a01:ad20::/32"
"2a01:b060::/32"
"2a01:b300::/29"
"2a01:b5c0::/32"
"2a01:b680::/32"
"2a01:b900::/32"
"2a01:bdc0::/32"
"2a01:e2c0::/32"
"2a01:f400::/29"
"2a01:f640::/29"
"2a01:fc00::/29"
"2a01:ff40::/29"
"2a02:a0::/32"
"2a02:3b8::/32"
"2a02:7b0::/32"
"2a02:8b0::/32"
"2a02:aa8::/29"
"2a02:be8::/32"
"2a02:2068::/29"
"2a02:2110::/32"
"2a02:2280::/29"
"2a02:23a0::/32"
"2a02:23c8::/32"
"2a02:25c0::/29"
"2a02:2740::/32"
"2a02:2808::/32"
"2a02:2810::/32"
"2a02:2a68::/29"
"2a02:2b60::/32"
"2a02:2cc0::/32"
"2a02:2e00::/27"
"2a02:2f80::/29"
"2a02:4420::/32"
"2a02:5100::/32"
"2a02:52e0::/32"
"2a02:5540::/32"
"2a02:5b00::/32"
"2a02:5bc0::/32"
"2a02:5dc0::/32"
"2a02:5ea0::/32"
"2a02:5fc0::/32"
"2a02:62c0::/32"
"2a02:6480::/32"
"2a02:6520::/32"
"2a02:69a0::/32"
"2a02:6b40::/32"
"2a02:7160::/32"
"2a02:7480::/32"
"2a02:75a0::/32"
"2a02:7c60::/32"
"2a02:7ce0::/32"
"2a02:9000::/23"
"2a02:a800::/26"
"2a02:ad80::/29"
"2a02:c690::/31"
"2a02:ee40::/29"
"2a02:f4c0::/29"
"2a03:1c0::/32"
"2a03:440::/32"
"2a03:680::/32"
"2a03:b40::/32"
"2a03:1200::/32"
"2a03:19e0::/32"
"2a03:1c40::/32"
"2a03:1cc0::/32"
"2a03:1d20::/32"
"2a03:23a0::/32"
"2a03:2460::/32"
"2a03:26a0::/32"
"2a03:2e00::/32"
"2a03:30c0::/32"
"2a03:3120::/32"
"2a03:3660::/32"
"2a03:3900::/32"
"2a03:3ba0::/32"
"2a03:3be0::/32"
"2a03:3c40::/32"
"2a03:3c60::/29"
"2a03:3d20::/32"
"2a03:3d60::/29"
"2a03:4460::/32"
"2a03:44a0::/32"
"2a03:45c0::/32"
"2a03:4e00::/32"
"2a03:51c0::/29"
"2a03:5560::/32"
"2a03:5940::/32"
"2a03:5c20::/32"
"2a03:5e60::/32"
"2a03:61e0::/32"
"2a03:6280::/29"
"2a03:62c0::/32"
"2a03:6320::/32"
"2a03:6ca0::/32"
"2a03:7120::/32"
"2a03:7140::/32"
"2a03:7260::/32"
"2a03:7480::/32"
"2a03:7680::/32"
"2a03:7ac0::/32"
"2a03:7ce0::/32"
"2a03:8040::/32"
"2a03:81a0::/32"
"2a03:85e0::/32"
"2a03:86c0::/32"
"2a03:8e80::/32"
"2a03:9320::/32"
"2a03:9340::/32"
"2a03:9520::/32"
"2a03:9580::/32"
"2a03:9680::/32"
"2a03:99a0::/32"
"2a03:9bc0::/32"
"2a03:9d20::/32"
"2a03:a320::/32"
"2a03:a420::/32"
"2a03:a680::/32"
"2a03:a740::/32"
"2a03:ab80::/32"
"2a03:ad80::/29"
"2a03:ae80::/32"
"2a03:b740::/32"
"2a03:bb00::/29"
"2a03:bc80::/29"
"2a03:c600::/32"
"2a03:c7c0::/29"
"2a03:c880::/32"
"2a03:d300::/32"
"2a03:d3c0::/29"
"2a03:de40::/32"
"2a03:e3c0::/29"
"2a03:e4c0::/29"
"2a03:e680::/32"
"2a03:e900::/32"
"2a03:ea80::/32"
"2a03:f6c0::/32"
"2a04:300::/29"
"2a04:c80::/29"
"2a04:e80::/29"
"2a04:1ec0::/29"
"2a04:2c40::/29"
"2a04:3240::/29"
"2a04:3300::/29"
"2a04:3a40::/32"
"2a04:41c0::/29"
"2a04:4ec0::/29"
"2a04:5800::/29"
"2a04:6c00::/29"
"2a04:7280::/29"
"2a04:7480::/29"
"2a04:7540::/29"
"2a04:7940::/29"
"2a04:7c40::/29"
"2a04:7cc0::/29"
"2a04:7ec0::/29"
"2a04:8100::/29"
"2a04:8bc0::/29"
"2a04:8fc0::/29"
"2a04:9000::/29"
"2a04:9500::/29"
"2a04:9800::/29"
"2a04:9900::/29"
"2a04:9980::/29"
"2a04:a280::/29"
"2a04:a450::/31"
"2a04:a980::/29"
"2a04:b000::/29"
"2a04:b380::/29"
"2a04:b880::/29"
"2a04:c300::/29"
"2a04:d700::/29"
"2a04:e180::/29"
"2a04:e2c0::/29"
"2a04:fec0::/32"
"2a05:180::/29"
"2a05:340::/29"
"2a05:5c0::/29"
"2a05:8c0::/29"
"2a05:c80::/29"
"2a05:dc0::/29"
"2a05:12c0::/29"
"2a05:2040::/29"
"2a05:2ac0::/29"
"2a05:3900::/29"
"2a05:3dc0::/29"
"2a05:4300::/29"
"2a05:4380::/32"
"2a05:4440::/29"
"2a05:4700::/29"
"2a05:4ac0::/32"
"2a05:4cc0::/29"
"2a05:4d40::/29"
"2a05:5180::/29"
"2a05:52c0::/29"
"2a05:5c80::/29"
"2a05:5d40::/29"
"2a05:6500::/29"
"2a05:6580::/29"
"2a05:65c0::/29"
"2a05:6940::/29"
"2a05:6b40::/29"
"2a05:7080::/29"
"2a05:7440::/29"
"2a05:7900::/29"
"2a05:8600::/29"
"2a05:8740::/29"
"2a05:8e00::/29"
"2a05:9980::/29"
"2a05:9b00::/29"
"2a05:9c40::/29"
"2a05:a4c0::/29"
"2a05:a780::/29"
"2a05:a800::/29"
"2a05:af00::/29"
"2a05:c380::/29"
"2a05:c7c0::/29"
"2a05:ce00::/29"
"2a05:e0c0::/29"
"2a05:e280::/29"
"2a05:e400::/29"
"2a05:e6c0::/29"
"2a05:ea40::/29"
"2a05:ed40::/29"
"2a05:ee40::/29"
"2a05:eec0::/29"
"2a05:f8c0::/29"
"2a05:f980::/29"
"2a06:6c0::/29"
"2a06:f80::/29"
"2a06:1440::/29"
"2a06:17c0::/29"
"2a06:1880::/29"
"2a06:1f80::/29"
"2a06:37c0::/29"
"2a06:3c00::/29"
"2a06:3f80::/29"
"2a06:44c0::/29"
"2a06:5340::/29"
"2a06:58c0::/29"
"2a06:60c0::/29"
"2a06:6100::/29"
"2a06:6380::/29"
"2a06:7540::/29"
"2a06:8840::/29"
"2a06:8c40::/29"
"2a06:8f40::/29"
"2a06:9940::/29"
"2a06:9980::/29"
"2a06:a6c0::/29"
"2a06:a8c0::/29"
"2a06:ab80::/29"
"2a06:ae80::/29"
"2a06:b4c0::/29"
"2a06:b980::/29"
"2a06:c980::/29"
"2a06:ce00::/29"
"2a06:ce40::/29"
"2a06:d080::/29"
"2a06:d600::/29"
"2a06:d840::/29"
"2a06:da00::/29"
"2a06:e140::/29"
"2a06:e240::/29"
"2a06:e2c0::/29"
"2a06:e540::/29"
"2a06:e840::/29"
"2a06:f0c0::/29"
"2a06:f380::/29"
"2a06:f440::/29"
"2a06:f6c0::/29"
"2a06:f840::/29"
"2a06:fc80::/29"
"2a07:100::/29"
"2a07:480::/29"
"2a07:16c0::/29"
"2a07:1a00::/29"
"2a07:2040::/29"
"2a07:2380::/29"
"2a07:2a00::/29"
"2a07:2bc0::/29"
"2a07:3000::/29"
"2a07:3a00::/29"
"2a07:3d80::/29"
"2a07:4380::/29"
"2a07:4640::/29"
"2a07:4940::/29"
"2a07:5180::/29"
"2a07:5d00::/29"
"2a07:6540::/29"
"2a07:6840::/29"
"2a07:6ec0::/29"
"2a07:6f00::/29"
"2a07:7040::/29"
"2a07:7700::/32"
"2a07:7d00::/29"
"2a07:7fc0::/29"
"2a07:80c0::/29"
"2a07:8a80::/29"
"2a07:8b00::/29"
"2a07:8b40::/29"
"2a07:8e40::/29"
"2a07:9040::/29"
"2a07:9cc0::/29"
"2a07:a180::/29"
"2a07:a280::/29"
"2a07:a4c0::/29"
"2a07:a7c0::/29"
"2a07:ad40::/29"
"2a07:b4c0::/29"
"2a07:b740::/29"
"2a07:be40::/29"
"2a07:bec0::/29"
"2a07:c2c0::/29"
"2a07:c340::/29"
"2a07:cf00::/29"
"2a07:d000::/24"
"2a07:d900::/29"
"2a07:e280::/29"
"2a07:e980::/29"
"2a07:f740::/29"
"2a07:f7c0::/29"
"2a07:fb80::/29"
"2a07:fec0::/29"
"2a09:880::/29"
"2a09:b40::/29"
"2a09:d00::/29"
"2a09:f40::/29"
"2a09:1780::/29"
"2a09:1ac0::/29"
"2a09:1ec0::/29"
"2a09:3100::/29"
"2a09:3840::/29"
"2a09:39c0::/29"
"2a09:3c40::/29"
"2a09:46c0::/29"
"2a09:4e40::/29"
"2a09:5000::/29"
"2a09:55c0::/29"
"2a09:74c0::/29"
"2a09:7840::/29"
"2a09:85c0::/32"
"2a09:8ac0::/29"
"2a09:8fc0::/29"
"2a09:9140::/29"
"2a09:ab40::/29"
"2a09:be00::/32"
"2a09:c0c0::/29"
"2a09:c100::/32"
"2a09:c5c0::/29"
"2a09:c740::/29"
"2a09:cc40::/29"
"2a09:cdc0::/29"
"2a09:cf40::/29"
"2a09:d940::/29"
"2a09:dd40::/29"
"2a09:eac0::/29"
"2a09:eb40::/29"
"2a09:f080::/29"
"2a09:f2c0::/29"
"2a09:f4c0::/29"
"2a09:fbc0::/29"
"2a09:fc40::/29"
"2a09:fcc0::/29"
"2a0a:180::/29"
"2a0a:680::/29"
"2a0a:8c0::/29"
"2a0a:c00::/29"
"2a0a:1140::/29"
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
