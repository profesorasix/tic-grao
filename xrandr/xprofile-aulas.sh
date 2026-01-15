#!/bin/bash

if [ $(hostname) = aula013pc00 ]
then
	xrandr --newmode "1280x1024_60.00"  109.00  1280 1368 1496 1712  1024 1027 1034 1063 -hsync +vsync
	xrandr --newmode "1440x900_60.00"  106.50  1440 1528 1672 1904  900 903 909 934 -hsync +vsync
	xrandr --newmode "1600x900_60.00"  118.25  1600 1696 1856 2112  900 903 908 934 -hsync +vsync
	xrandr --addmode VGA-1 1280x1024_60.00
	xrandr --addmode VGA-1 1440x900_60.00
	xrandr --addmode VGA-1 1600x900_60.00
	xrandr --addmode HDMI-1 1600x900_60.00
	xrandr --output VGA-1 --mode "1920x1080"
	xrandr --output VGA-1 --pos 0x0+0+0
	xrandr --output DP-2 --mode 1600x900
	xrandr --output DP-2 --pos 1920x0+1920+0 --rotate normal
	xrandr --output HDMI-1 --mode "1600x900_60.00"
	xrandr --output HDMI-1 --pos 1920x0+1920+0 --rotate normal

elif [ $(hostname) = aula015pc00 ]
then
	xrandr --newmode "1280x1024_60.00"  109.00  1280 1368 1496 1712  1024 1027 1034 1063 -hsync +vsync
	xrandr --newmode "1440x900_60.00"  106.50  1440 1528 1672 1904  900 903 909 934 -hsync +vsync
	xrandr --addmode VGA-1 1280x1024_60.00
	xrandr --addmode VGA-1 1440x900_60.00
	xrandr --output VGA-1 --mode "1440x900_60.00"
	xrandr --output HDMI-1 --pos 1440x0 --mode 1600x900 --rotate normal 
	xrandr --output HDMI-2 --pos 0x0 --mode 1440x900 --rotate normal 

elif [ $(hostname) = aula082pc00 ]
then
	xrandr --newmode "1280x1024_60.00"  109.00  1280 1368 1496 1712  1024 1027 1034 1063 -hsync +vsync
	xrandr --newmode "1440x900_60.00"  106.50  1440 1528 1672 1904  900 903 909 934 -hsync +vsync
	xrandr --newmode "1600x900_60.00"  118.25  1600 1696 1856 2112  900 903 908 934 -hsync +vsync
	xrandr --addmode DP-3 1600x900_60.00
	xrandr --output DP-1 --mode "1600x900" 
	xrandr --output DP-1 --pos 1600x0+1600+0
	xrandr --output DP-2 --mode 1600x900 --primary
	xrandr --output DP-2 --pos 0x0+0+0 --rotate normal
	xrandr --output DP-3 --mode "1600x900_60.00"
	xrandr --output DP-3 --pos 0x0+0+0 --rotate normal

elif [ $(hostname) = aula072pc00 ]
then

else 
	echo "Ordenador no existente!!"
fi