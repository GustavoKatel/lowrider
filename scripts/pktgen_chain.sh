#!/bin/bash

if [ "$USER" != "root" ]; then
    echo "Requires root!"
    exit 1;
fi

./pktgen_sample03_burst_single_flow.sh -i virbr2 -d 192.168.50.4 -m 52:54:00:a3:83:f9 -t 1 -b 1 -c 0 &

echo "PKTGEN PID: $!"

sleep $1

cd .. && vagrant ssh client -- pkill -SIGINT ping

for job in `jobs -p`; do
    kill -TERM $job
done

pkill -TERM pktgen_sample

sudo -u gustavokatel pb push "teste ok"
