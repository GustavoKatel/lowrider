#!/bin/bash

INTERVAL="1"  # update interval in seconds

if [ $# -lt 3 ]; then
        echo
        echo "usage: $0 [network-interface] [duration in seconds] [output csv file without extension]"
        echo
        echo "e.g. $0 eth0 300 data"
        echo
        echo "shows stats: packets-per-second, mem, cpu and writes to data.csv"
        exit
fi

IF=$1
DURATION=$2
OUTPUT=$3
INTERVAL=1

OUTPUT_NET=$OUTPUT"_net.csv"
OUTPUT_VMSTAT=$OUTPUT"_vmstat.csv"

run_general() {
  rm -f /tmp/sar.bin  # clean prev data
  sar -ur $INTERVAL $DURATION -o /tmp/sar.bin > /dev/null
  sadf -dh /tmp/sar.bin -- -ru > $OUTPUT_VMSTAT

  # plot
  echo """
  set term png
  set grid
  set xlabel 't'
  set datafile separator ';'

  set output '$OUTPUT"_vmstat_cpu.png"'
  set title 'general - cpu'
  set ylabel '%cpu'
  plot '$OUTPUT_VMSTAT' using 0:5 with lines

  set output '$OUTPUT"_vmstat_mem.png"'
  set title 'general - mem'
  set ylabel '%mem'
  plot '$OUTPUT_VMSTAT' using 0:13 with lines

  """ | gnuplot > /dev/null 2>&1
}

TBS_0=`cat /sys/class/net/$IF/statistics/tx_bytes`
RBS_0=`cat /sys/class/net/$IF/statistics/rx_bytes`

TPKTS_0=`cat /sys/class/net/$IF/statistics/tx_packets`
RPKTS_0=`cat /sys/class/net/$IF/statistics/rx_packets`

# collect vm statistics
run_general &

echo "tx_pps,tx_kpbs,tx_kbs,tx_pkts,rx_pps,rx_kpbs,rx_kbs,rx_pkts" > $OUTPUT_NET

t=0
while (( t < DURATION)); do
        ((t++))

        # pps
        RPPS1=`cat /sys/class/net/$IF/statistics/rx_packets`
        TPPS1=`cat /sys/class/net/$IF/statistics/tx_packets`

        # kbps
        RKBPS1=`cat /sys/class/net/$IF/statistics/rx_bytes`
        TKBPS1=`cat /sys/class/net/$IF/statistics/tx_bytes`

        sleep $INTERVAL

        # pps
        RPPS2=`cat /sys/class/net/$IF/statistics/rx_packets`
        TPPS2=`cat /sys/class/net/$IF/statistics/tx_packets`
        TXPPS=`expr $TPPS2 - $TPPS1`
        RXPPS=`expr $RPPS2 - $RPPS1`

        # kbps
        RKBPS2=`cat /sys/class/net/$IF/statistics/rx_bytes`
        TKBPS2=`cat /sys/class/net/$IF/statistics/tx_bytes`
        TBPS=`expr $TKBPS2 - $TKBPS1`
        RBPS=`expr $RKBPS2 - $RKBPS1`
        TKBPS=`expr $TBPS / 1024`
        RKBPS=`expr $RBPS / 1024`

        # kbs
        TKBS=`expr $TKBPS2 - $TBS_0`
        TKBS=`expr $TKBS / 1024`
        RKBS=`expr $RKBPS2 - $RBS_0`
        RKBS=`expr $RKBS / 1024`

        # pkts total
        TPKTS=`expr $TPPS2 - $TPKTS_0`
        RPKTS=`expr $RPPS2 - $RPKTS_0`

        echo "TX $IF: $TXPPS pkts/s ($TPKTS pkts) RX $IF: $RXPPS pkts/s ($RPKTS pkts)"
        echo "TX $IF: $TKBPS kb/s ($TKBS Kbs) RX $IF: $RKBPS kb/s ($RKBS Kbs)"
        echo

        # echo "tx_pps,tx_kpbs,tx_kbs,tx_pkts,rx_pps,rx_kpbs,rx_kbs,rx_pkts" > $OUTPUT.csv
        echo "$TXPPS,$TKBPS,$TKBS,$TPKTS,$RXPPS,$RKBPS,$RKBS,$RPKTS" >> $OUTPUT_NET
done