#!/bin/bash

INTERFACES_SYS_DIR="/sys/class/net"

get_total_bytes() {
    STATS_BYTES=$1
    BYTES=0

    for IFACE in $(ls $INTERFACES_SYS_DIR)
    do
        [[ $IFACE == "lo" ]] && continue
        BYTES=$((BYTES + $(cat $INTERFACES_SYS_DIR/$IFACE/statistics/$STATS_BYTES)))
    done
    echo "$BYTES"
}

# Entry point
case $1 in
    "download") STATS_BYTES="rx_bytes"; ;;
    "upload") STATS_BYTES="tx_bytes"; ;;
    *) echo "Error: invalid parameter"; exit 1; ;;
esac

# run
SAMPLE1=$(get_total_bytes $STATS_BYTES)
sleep 1
SAMPLE2=$(get_total_bytes $STATS_BYTES)

BITRATE=$(((${SAMPLE2} - ${SAMPLE1}) * 8))
echo "$BITRATE"
