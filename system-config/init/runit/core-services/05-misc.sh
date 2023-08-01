# vim: set ts=4 sw=4 et:

install -m0664 -o root -g utmp /dev/null /run/utmp
halt -B

seedrng 2> /dev/null >&2 || true

msg "Creating localhost network interface"
ip link set up dev lo

echo -n 'moon' > /proc/sys/kernel/hostname
