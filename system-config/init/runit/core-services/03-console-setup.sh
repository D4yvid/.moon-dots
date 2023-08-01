# vim: set ts=4 sw=4 et:

source /etc/vconsole.conf 2> /dev/null >&2

HARDWARECLOCK=localtime

msg "Set keyboard layout to 'br-abnt2' in TTYs"
loadkeys -q -u br-abnt2 &

msg "Set up runtime clock to 'localtime'"
TZ=$TIMEZONE hwclock --systz \
  ${HARDWARECLOCK:+--$(echo $HARDWARECLOCK |tr A-Z a-z) --noadjfile} || emergency_shell
