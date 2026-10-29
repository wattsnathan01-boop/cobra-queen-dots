#!/usr/bin/env bash
# COBRA QUEEN power menu — rofi -dmenu

lock="  lock"
logout="󰍃  logout"
suspend="󰒲  suspend"
reboot="  reboot"
shutdown="  shut down"

choice=$(printf '%s\n' "$lock" "$suspend" "$logout" "$reboot" "$shutdown" \
    | rofi -dmenu -i -p "power" \
           -theme ~/.config/rofi/cobra.rasi \
           -theme-str 'window { width: 340px; } listview { lines: 5; } mode-switcher { enabled: false; }')

case "$choice" in
    "$lock")     hyprlock ;;
    "$suspend")  systemctl suspend ;;
    "$logout")   hyprctl dispatch exit ;;
    "$reboot")   systemctl reboot ;;
    "$shutdown") systemctl poweroff ;;
esac
