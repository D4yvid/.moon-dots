set -f path = ( $home/.cargo/bin $home/.dots/bin $path )

if (`tty` == "/dev/tty1") then
	mooninit
endif
