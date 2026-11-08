#!/usr/bin/env bash
# COBRA QUEEN power menu — rofi -dmenu

lock="  lock"
logout="󰍃  logout"
suspend="󰒲  suspend"
reboot="  reboot"
shutdown="  shut down"

# Under uwsm the session is a systemd service, so stop it properly; otherwise use the
# Lua dispatcher (Hyprland 0.55+ no longer accepts `hyprctl dispatch exit`)
log_out() {
    if command -v uwsm >/dev/null && uwsm check is-active; then
        uwsm stop
    else
        hyprctl dispatch 'hl.dsp.exit()'
    fi
}

choice=$(printf '%s\n' "$lock" "$suspend" "$logout" "$reboot" "$shutdown" \
    | rofi -dmenu -i -p "power" \
           -theme ~/.config/rofi/cobra.rasi \
           -theme-str 'window { width: 340px; } listview { lines: 5; } mode-switcher { enabled: false; }')

case "$choice" in
    "$lock")     hyprlock ;;
    "$suspend")  systemctl suspend ;;
    "$logout")   log_out ;;
    "$reboot")   systemctl reboot ;;
    "$shutdown") systemctl poweroff ;;
esac
