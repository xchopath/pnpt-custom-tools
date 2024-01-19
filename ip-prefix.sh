#!/bin/bash

function prefix_to_bit_netmask() {
  prefix=$1;
  shift=$(( 32 - prefix ));
  bitmask=""
  for (( i=0; i < 32; i++ )); do
    num=0
    if [ $i -lt ${prefix} ]; then
      num=1
    fi
    space=
    if [ $(( i % 8 )) -eq 0 ]; then
      space=" ";
    fi
    bitmask="${bitmask}${space}${num}"
  done
  echo ${bitmask}
}

function bit_netmask_to_wildcard_netmask() {
  bitmask=$1;
  wildcard_mask=
  for octet in ${bitmask}; do
    wildcard_mask="${wildcard_mask} $(( 255 - 2#$octet ))"
  done
  echo $wildcard_mask;
}


ip="${1}"
if [[ -z ${ip} ]]; then
  echo "Run: ${0} 10.10.10.0/24"
  exit
fi

net=$(echo ${ip} | cut -d '/' -f 1);
prefix=$(echo ${ip} | cut -d '/' -f 2);
bit_netmask=$(prefix_to_bit_netmask ${prefix});
wildcard_mask=$(bit_netmask_to_wildcard_netmask "${bit_netmask}");
str=
for (( i = 1; i <= 4; i++ )); do
  range=$(echo ${net} | cut -d '.' -f $i)
  mask_octet=$(echo ${wildcard_mask} | cut -d ' ' -f $i)
  if [ $mask_octet -gt 0 ]; then
      range="{0..${mask_octet}}";
  fi
  str="${str} ${range}"
done
ips=$(echo ${str} | sed "s, ,\\.,g");
eval echo ${ips} | tr ' ' '\012'
