Based on: https://github.com/iovisor/xdp-vagrant

In order to try out the XDP functionality, it would be nice to have a
playground. This could be useful if you are worried about experimental kernels
(not sure why you're reading this, but hey...) or if you don't have the required
hardware to run XDP.

This repo thus provides a vagrant based vm for you to try it out. We'll simply
install the necessary kernel and some userspace tools to be able to load your
program. Note that the vm will use an e1000 driver, which won't show much
performance difference from the normal stack. Trust us that it would perform
much better on real hardware.

Host prerequisites:
* libvirt
* vagrant
* vagrant-libvirt

(If someone tries this on non-libvirt vagrant, file a /issue and we can
simplify the prerequisites.)

For convenience, there is a pre-built 4.8 rc kernel which includes the e1000
patch from [git:ast/xdp](http://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/commit/?h=xdp&id=e643c99556770a6b77c1330bcd9d28d578026788). Feel free to build your own, or if you're reading
this from the future, likely 4.9 will have support for it.


First, bring the vagrant box up, with userspace tools (bcc) and custom kernel.
```
git clone https://github.com/iovisor/xdp-vagrant
cd xdp-vagrant
vagrant up
# note that some apt errors above are expected
vagrant ssh
uname -r
# confirm that the running kernel is something like 4.7.0-07282016-torvalds+
```

You should find that the vm has two interfaces, we'll use the second one for
testing and the first one for ssh.
```
vagrant@vagrant-ubuntu-trusty-64:~$ ip -4 a
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.121.153/24 brd 192.168.121.255 scope global eth0
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.50.4/24 brd 192.168.50.255 scope global eth1
```

Let's start a udp packet performance stress test. Run this from the host in
another shell:
```
./setup-pktgen.sh
MAC=ETH1_MAC_INSIDE_THE_VM
IP=ETH1_IP_INSIDE_THE_VM
VNET=TAP_DEVICE_OF_ETH1_OUTSIDE_THE_VM
sudo ./pktgen_sample03_burst_single_flow.sh -i $VNET -d $IP -m $MAC -t 1 -b 1 -c 0
```

Now, simply try out the sample xdp script. This comes from the libbcc-examples
package.
```
sudo /usr/share/bcc/examples/networking/xdp/xdp_drop_count.py eth1
Printing drops per IP protocol-number, hit CTRL+C to stop
17: 179118 pkt/s
17: 509420 pkt/s
...
```
