#!/usr/bin/env bash
# ── COBRA QUEEN · installer ──────────────────────
# For a fresh Arch install on the Alienware 15 (DA15260):
#   Intel Core 7 240H + RTX 5060 Laptop (hybrid), Realtek ALC236 via Intel SST,
#   MediaTek MT7920 Wi-Fi.
# Run as your normal user (not root) from the repo folder:  bash install.sh
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$HOME/.config"
STAMP="$(date +%Y%m%d-%H%M%S)"

say() { printf '\n\033[38;2;59;240;182m==>\033[0m %s\n' "$*"; }

if [ "$EUID" -eq 0 ]; then
    echo "Run this as your normal user, not root." >&2
    exit 1
fi

# Files edited on Windows may carry CRLF line endings — strip them
find "$DIR" -path "$DIR/.git" -prune -o -type f \
    \( -name '*.sh' -o -name '*.conf' -o -name 'config' -o -name '*.qml' -o -name '*.desktop' \) \
    -exec sed -i 's/\r$//' {} +

# ── 1. multilib (32-bit libs for Steam / NVIDIA) ──
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    say "Enabling multilib"
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
fi
sudo pacman -Syu --noconfirm

# ── 2. Packages ───────────────────────────────────
NVIDIA=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-prime
        linux-headers egl-wayland libva-nvidia-driver)
INTEL=(mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver intel-ucode)
AUDIO=(pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
       sof-firmware alsa-ucm-conf alsa-utils pavucontrol)
NET=(networkmanager network-manager-applet bluez bluez-utils blueman linux-firmware)
DESKTOP=(hyprland hyprlock hypridle hyprpaper hyprpolkitagent
         xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt6-wayland qt5-wayland
         waybar rofi kitty mako fastfetch thunar gvfs
         brightnessctl playerctl cava grim slurp wl-clipboard cliphist
         papirus-icon-theme ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji
         qt6ct nwg-look)
LOGIN=(sddm xorg-server qt6-declarative qt6-svg)
TOOLS=(git base-devel curl unzip)

say "Installing packages"
sudo pacman -S --needed "${NVIDIA[@]}" "${INTEL[@]}" "${AUDIO[@]}" "${NET[@]}" \
    "${DESKTOP[@]}" "${LOGIN[@]}" "${TOOLS[@]}"

# ── 3. NVIDIA setup ───────────────────────────────
say "Configuring NVIDIA (open driver, early KMS, suspend support)"
sudo tee /etc/modprobe.d/nvidia.conf >/dev/null <<'EOF'
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF
if grep -q '^MODULES=()' /etc/mkinitcpio.conf; then
    sudo sed -i 's/^MODULES=()/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
fi
# Keep nouveau out of the initramfs
sudo sed -i '/^HOOKS=/ s/ kms//' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# ── 4. AUR helper + Chrome ───────────────────────
if ! command -v yay >/dev/null; then
    say "Installing yay (AUR helper)"
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi
say "Installing Google Chrome"
yay -S --needed --noconfirm google-chrome

# ── 5. Fonts (system-wide so SDDM can use them) ───
if [ ! -f /usr/local/share/fonts/Orbitron.ttf ]; then
    say "Installing Orbitron font"
    sudo mkdir -p /usr/local/share/fonts
    sudo curl -fsSL -o /usr/local/share/fonts/Orbitron.ttf \
        "https://github.com/google/fonts/raw/main/ofl/orbitron/Orbitron%5Bwght%5D.ttf"
    sudo fc-cache -f
fi

# ── 6. Dotfiles ───────────────────────────────────
say "Linking configs"
chmod +x "$DIR/dots/rofi/powermenu.sh"
mkdir -p "$CONFIG"
for d in hypr waybar rofi kitty mako fastfetch cava; do
    target="$CONFIG/$d"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "$target.bak-$STAMP"
        echo "    backed up $target -> $target.bak-$STAMP"
    fi
    ln -sfn "$DIR/dots/$d" "$target"
    echo "    linked $target"
done
ln -sfn "$DIR/dots/chrome-flags.conf" "$CONFIG/chrome-flags.conf"

# Avatar for SDDM / AccountsService
cp "$DIR/dots/hypr/wallpapers/cobra-avatar.png" "$HOME/.face.icon"
sudo mkdir -p /var/lib/AccountsService/icons /var/lib/AccountsService/users
sudo cp "$DIR/dots/hypr/wallpapers/cobra-avatar.png" "/var/lib/AccountsService/icons/$USER"
printf '[User]\nIcon=/var/lib/AccountsService/icons/%s\n' "$USER" \
    | sudo tee "/var/lib/AccountsService/users/$USER" >/dev/null

# ── 7. SDDM theme ─────────────────────────────────
say "Installing SDDM theme"
THEME=/usr/share/sddm/themes/cobra-queen
sudo rm -rf "$THEME"
sudo cp -r "$DIR/sddm/cobra-queen" "$THEME"
sudo mkdir -p "$THEME/assets"
sudo cp "$DIR/dots/hypr/wallpapers/cobra-queen.png" "$THEME/assets/"
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=cobra-queen\n' | sudo tee /etc/sddm.conf.d/cobra-queen.conf >/dev/null

# ── 8. Services ───────────────────────────────────
say "Enabling services"
sudo systemctl enable NetworkManager bluetooth sddm \
    nvidia-suspend nvidia-hibernate nvidia-resume
systemctl --user enable pipewire pipewire-pulse wireplumber || true

say "Done!"
cat <<'EOF'
Reboot and you should land on the Cobra Queen login screen.

After rebooting, check:
  nvidia-smi                 → RTX 5060 listed
  prime-run glxinfo | grep renderer   (needs mesa-utils)
  wpctl status               → speakers listed as a sink
  hyprctl monitors           → eDP-1 at 1920x1200@165
EOF
