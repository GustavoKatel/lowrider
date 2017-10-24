#!/bin/bash

count=$1
duration=$2
cmd=${@:3} # arguments tail. Everything but the first

killalljobs() {

    for job in `jobs -p`; do
        kill -SIGINT $job
    done

}

trap "killalljobs" SIGINT

# start all
for i in `seq 1 $count`; do
    $cmd &
done

if (( duration > 0 )); then
    $(sleep $duration; killalljobs) &
fi

# wait all
for job in `jobs -p`; do
    wait $job
done

echo "Done."