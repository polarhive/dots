date_formatted=$(date "+%H:%M")
battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity)
echo $date_formatted — $battery_capacity