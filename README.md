<div align="center">

# 🐧 Hyprland Installer

### ✨ The Ultimate Arch Linux + Hyprland + Caelestia Shell Installer

<p align="center">
A complete, automated and interactive installer for <b>Arch Linux</b>, featuring <b>Hyprland</b>, <b>Wayland</b>, <b>PipeWire</b>, <b>Caelestia Shell</b>, AMD drivers and a fully configured modern desktop environment.
</p>

<br>

<img src="https://img.shields.io/github/stars/doglytdc/hyprland?style=for-the-badge&logo=github">
<img src="https://img.shields.io/github/forks/doglytdc/hyprland?style=for-the-badge&logo=github">
<img src="https://img.shields.io/github/issues/doglytdc/hyprland?style=for-the-badge">
<img src="https://img.shields.io/github/license/doglytdc/hyprland?style=for-the-badge">
<img src="https://img.shields.io/badge/Arch-Linux-1793D1?style=for-the-badge&logo=arch-linux">
<img src="https://img.shields.io/badge/Hyprland-Wayland-00BFFF?style=for-the-badge">
<img src="https://img.shields.io/badge/Caelestia-Shell-7C3AED?style=for-the-badge">
<img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge">

<br><br>

<img src="assets/banner.png" width="100%">

<br>

[🚀 Installation](#-installation) •
[✨ Features](#-features) •
[📦 Packages](#-installed-packages) •
[⌨ Shortcuts](#-keyboard-shortcuts) •
[🛠 Troubleshooting](#-troubleshooting)

</div>

---

# 🚀 Installation

## ⭐ Recommended

Clone the repository and run the installer.

```bash
git clone https://github.com/doglytdc/hyprland.git && \
cd hyprland && \
chmod +x install.sh && \
sudo ./install.sh
```

---

## ⚡ One-Line Installation

Run directly from GitHub.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/doglytdc/hyprland/main/install.sh)
```

or

```bash
bash <(wget -qO- https://raw.githubusercontent.com/doglytdc/hyprland/main/install.sh)
```

---

# ✨ Features

- 🚀 Fully automatic installation
- 🎨 Complete Hyprland configuration
- 🌌 Caelestia Shell installation
- ⚙️ Automatic dependency detection
- 📦 Smart package installation
- 🔄 Safe to run multiple times
- 💾 Automatic configuration backups
- 🖥 Beautiful interactive terminal interface
- ⚡ Fast installation process
- 🔊 PipeWire audio configuration
- 🌐 NetworkManager setup
- 🔔 Dunst notifications
- 📂 Thunar file manager
- 🚀 Rofi launcher
- 🎮 AMD GPU support
- 🔥 Vulkan support
- 📡 Bluetooth configuration
- 🛠 Automatic fixes for common issues
- 📋 Final verification
- 🎯 Post-install guide

---

# 📦 Installed Packages

| Category | Components |
|----------|------------|
| 🖥 Desktop | Hyprland, Wayland |
| 🎨 Theme | Caelestia Shell |
| 🔊 Audio | PipeWire, WirePlumber, Pavucontrol |
| 💻 Terminal | Foot, Kitty, Alacritty |
| 📂 File Manager | Thunar |
| 🚀 Launcher | Rofi |
| 🔔 Notifications | Dunst |
| 📸 Screenshot | Flameshot |
| 🌐 Network | NetworkManager |
| 📡 Bluetooth | Bluez |
| 🎮 Graphics | Mesa, Vulkan |
| ⚡ Drivers | AMD GPU Drivers |
| 🔧 Development | Git, CMake, Ninja, Base-devel |
| 📊 Utilities | Curl, Wget, Nano, Vim, Htop |

---

# ⌨ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Super + Enter | Open Terminal |
| Super + D | Application Launcher |
| Super + E | File Manager |
| Super + Q | Close Window |
| Super + F | Fullscreen |
| Super + Space | Toggle Floating |
| Super + Shift + R | Reload Hyprland |
| Super + Arrows | Change Focus |
| Super + Shift + Arrows | Move Window |
| Super + Mouse | Move Window |
| Super + Scroll | Change Workspace |

---

# 📸 Preview

<p align="center">

<img src="assets/desktop.png" width="95%">

<br><br>

<img src="assets/installer.png" width="95%">

</p>

---

# 🛠 Troubleshooting

### Hyprland doesn't start

```bash
sudo pacman -S hyprland hyprland-protocols
```

---

### Restart NetworkManager

```bash
sudo systemctl restart NetworkManager
```

---

### Reload Hyprland

```bash
hyprctl reload
```

---

### Update System

```bash
sudo pacman -Syu
```

---

### Enable Caelestia Shell

```bash
qs -c caelestia
```

---

# 📂 Repository Structure

```
hyprland
│
├── install.sh
├── README.md
├── LICENSE
├── assets
│   ├── banner.png
│   ├── desktop.png
│   └── installer.png
└── configs
```

---

# 💻 Tested On

| Hardware | Status |
|----------|--------|
| HP EliteBook 845 G7 | ✅ |
| AMD Ryzen 5 PRO 4650U | ✅ |
| AMD Radeon Graphics | ✅ |
| Arch Linux | ✅ |

---

# 🗺 Roadmap

- [x] Automatic installer
- [x] Interactive menu
- [x] Hyprland setup
- [x] PipeWire
- [x] AMD Drivers
- [x] Caelestia Shell
- [x] Backup existing configuration
- [ ] Intel GPU support
- [ ] NVIDIA support
- [ ] Automatic wallpaper installer
- [ ] Plymouth Theme
- [ ] SDDM Theme
- [ ] Automatic updates

---

# ⭐ Support

If you enjoyed this project, consider giving it a ⭐ on GitHub.

It helps the project reach more Arch Linux users.

---

<div align="center">

## ❤️ Made with passion for the Arch Linux community

### Developed by DoglyTDC

⭐ Star this repository if it helped you!

</div>
