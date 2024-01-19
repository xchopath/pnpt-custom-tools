#!/usr/bin/env bash

IP="${1}"

function portknock() {
	IP="${1}"
	PORT="${2}"
	NC=$(nc ${IP} ${PORT} -vvz 2>&1)
	if [[ ${NC} =~ ' succeeded!' ]]; then
		echo "${IP}:${PORT} (${NC})."
	else
		return 0
	fi
}

MULTIPROC=100
(
  for PORT in {1..65535}
  do 
    ((PROCNUM=PROCNUM%MULTIPROC)); ((PROCNUM++==0)) && wait
    portknock "${IP}" "${PORT}" & 
  done
  wait
)
