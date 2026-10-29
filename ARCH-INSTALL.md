# Installing Arch on the new drive (dual boot with Windows)

Laptop: **Alienware 15 (DA15260)**. Windows lives on the **512 GB KIOXIA NVMe**.
Arch goes on the **new drive** with its own boot partition, so Windows is never touched.
You pick the OS at power-on with **F12**.

---

## 0. Before you start (in Windows)

1. **Save your BitLocker recovery key.** Alienware laptops usually ship with device
   encryption on. Changing BIOS settings (step 1) can make Windows ask for this key.
   Get it from <https://account.microsoft.com/devices/recoverykey> and keep it on your phone.
2. **Turn off Fast Startup:** Control Panel → Power Options → *Choose what the power
   buttons do* → untick *Turn on fast startup*.
3. **Fit the new drive**, then check it shows in *Disk Management* (it may say
   "Not initialized", that's fine, **don't** format it). Note its **size**, as that's
   how you'll recognise it in the installer.
4. Download the Arch ISO from <https://archlinux.org/download/> and write it to a USB
   stick with **Rufus** (choose *DD image* mode when asked) or **Ventoy**.

## 1. BIOS (press F2 at the Alienware logo)

- **Secure Boot → Disabled** (the Arch USB won't boot otherwise).
- Leave the storage mode alone (RAID/VMD vs AHCI). Only revisit this if the
  installer can't see the drive.

## 2. Boot the USB

Power on → tap **F12** → pick the USB stick → *Arch Linux install medium*.

Connect to Wi-Fi (the MediaTek MT7920 works out of the box):

```sh
iwctl
[iwd]# station wlan0 scan
[iwd]# station wlan0 connect "YourNetwork"
[iwd]# exit
ping -c 3 archlinux.org
```

## 3. Identify the drives ⚠️ the important bit

```sh
lsblk -o NAME,SIZE,MODEL,TYPE
```

- `nvme0n1`, **~477G**, **KIOXIA**: this is **Windows. Do not select it.**
- The other disk (`sda` for a SATA HDD, or `nvme1n1` for a second NVMe) with the size
  you noted: **this is the one for Arch.**

## 4. Run archinstall

```sh
archinstall
```

| Setting | Choose |
|---|---|
| Mirrors | United Kingdom |
| Locales | keyboard `uk`, language `en_GB.UTF-8` |
| **Disk configuration** | *Use a best-effort default partition layout* → select **only the new drive** → filesystem `ext4` (or `btrfs` if you want snapshots) |
| Bootloader | `systemd-boot` |
| Hostname | `cobra` |
| Root password | set one |
| User account | your username, **superuser: yes** |
| Profile | *Minimal* (install.sh adds Hyprland and everything else) |
| Audio | `pipewire` |
| Kernels | `linux` |
| Network | *NetworkManager* |
| Additional packages | `git` |
| Timezone | `Europe/London` |

> Leave **Graphics driver** alone (Minimal profile); install.sh installs the correct
> **nvidia-open** driver, which is the only one that supports the RTX 50-series.

Install → when it finishes, choose **no** to chroot → `reboot` and pull the USB out.

## 5. First boot

Press **F12** and choose the new drive (shows as *Linux Boot Manager*).
To make Arch the default, move it to the top in BIOS → Boot sequence. Windows is
always one F12 away.

Log in on the text console, connect Wi-Fi with `nmtui`, then:

```sh
git clone https://github.com/wattsnathan01-boop/cobra-queen-dots.git ~/cobra-queen-dots
cd ~/cobra-queen-dots
bash install.sh
reboot
```

You'll land on the Cobra Queen login screen.

## Troubleshooting

- **Black screen after login:** press `Ctrl+Alt+F3`, log in, run `journalctl -b -p err`.
- **No sound:** `wpctl status`. If no sink is listed, check `sof-firmware` is installed and reboot.
- **External monitor blank:** uncomment the NVIDIA env block in `~/.config/hypr/hyprland.conf`.
- **Red error bar in Hyprland:** a config line uses old syntax. Copy the message and fix that line.
