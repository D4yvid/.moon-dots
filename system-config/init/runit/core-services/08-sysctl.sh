# vim: set ts=4 sw=4 et:

if [ -x /sbin/sysctl -o -x /bin/sysctl ]; then
    msg "Loading system control settings (sysctl)"
    mkdir -p /run/vsysctl.d
    for i in /run/sysctl.d/*.conf \
        /etc/sysctl.d/*.conf \
        /usr/local/lib/sysctl.d/*.conf \
        /usr/lib/sysctl.d/*.conf; do

        if [ -e "$i" ] && [ ! -e "/run/vsysctl.d/${i##*/}" ]; then
            ln -s "$i" "/run/vsysctl.d/${i##*/}" 2> /dev/null >&2
        fi
    done
    for i in /run/vsysctl.d/*.conf; do
        sysctl -p "$i" 2> /dev/null >&2
    done
    rm -rf -- /run/vsysctl.d 2> /dev/null >&2
    sysctl -p /etc/sysctl.conf 2> /dev/null >&2
fi
