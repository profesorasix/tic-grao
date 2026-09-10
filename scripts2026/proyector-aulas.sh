#!/bin/bash
#Updated to 13,15,82,148,132

xrandr --newmode "1280x1024_60.00"  109.00  1280 1368 1496 1712  1024 1027 1034 1063 -hsync +vsync
xrandr --newmode "1440x900_60.00"  106.50  1440 1528 1672 1904  900 903 909 934 -hsync +vsync
xrandr --newmode "1600x900_60.00"  118.25  1600 1696 1856 2112  900 903 908 934 -hsync +vsync
xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync

case `hostname` in 
aula013pc00)

	xrandr --addmode VGA-1 1280x1024_60.00
	xrandr --addmode VGA-1 1440x900_60.00
	xrandr --addmode VGA-1 1600x900_60.00
	xrandr --addmode HDMI-1 1600x900_60.00
	xrandr --output VGA-1 --mode "1920x1080" --output DP-2 --auto --right-of VGA-1 --output HDMI-1 --same-as DP-2	
	;;

aula014pc00)
	# TODO
	xrandr --addmode VGA-1 1280x1024_60.00
	xrandr --addmode VGA-1 1440x900_60.00
	xrandr --output VGA-1 --mode "1440x900_60.00"
	xrandr --output HDMI-1 --pos 1440x0 --mode 1600x900 --rotate normal 
	xrandr --output HDMI-2 --pos 0x0 --mode 1440x900 --rotate normal 
	;;

aula015pc00)
	xrandr --addmode VGA-1 1280x1024_60.00
	xrandr --addmode VGA-1 1440x900_60.00
	xrandr --output VGA-1 --mode "1440x900_60.00" --output HDMI-1 --auto --right-of VGA-1 --output HDMI-2 --mode "1440x900" --same-as VGA-1	
	;;


aula067pc00)
	xrandr --addmode VGA-1 1280x1024_60.00
	xrandr --addmode VGA-1 1440x900_60.00
	xrandr --output VGA-1 --mode "1440x900_60.00"
	xrandr --output HDMI-1 --pos 1440x0 --mode 1600x900 --rotate normal 
	xrandr --output HDMI-2 --pos 0x0 --mode 1440x900 --rotate normal 
	;;


aula072pc00)
	xrandr --addmode DP-3 1600x900_60.00
	xrandr --output DP-1 --auto --output DP-2 --auto --right-of DP-1 --output DP-3 --mode "1600x900_60.00" --same-as DP-1	
	;;

aula079pc00)
	#TODO
	xrandr --addmode VGA-1 1280x1024_60.00
	xrandr --addmode VGA-1 1440x900_60.00
	xrandr --output VGA-1 --mode "1440x900_60.00"
	xrandr --output HDMI-1 --pos 1440x0 --mode 1600x900 --rotate normal 
	xrandr --output HDMI-2 --pos 0x0 --mode 1440x900 --rotate normal 
	;;

aula082pc00)
	xrandr --addmode DP-3 1600x900_60.00
	xrandr --output DP-1 --auto --output DP-2 --auto --right-of DP-1 --output DP-3 --mode "1600x900_60.00" --same-as DP-1	
	;;


aula132pc00)
	xrandr --addmode HDMI-3 1600x900_60.00
	xrandr --addmode HDMI-3 1920x1080_60.00
	xrandr --output HDMI-2 --auto --output DP-2 --auto --right-of HDMI-2 --output HDMI-3 --mode 1600x900_60.00 --same-as DP-2	
	;;

aula148pc00)
	xrandr --addmode DP-3 1600x900_60.00
	xrandr --output DP-1 --auto --output DP-2 --auto --right-of DP-1 --output DP-3 --mode "1600x900_60.00" --same-as DP-1

	;;
esac
