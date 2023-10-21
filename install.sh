#!/bin/sh
clear
printf "polarhive's: arch-rice\n"
sleep 1
clear
printf "# works best on a fresh arch-install\n"
sleep 3
clear

printf "# chaotic-aur\n"
sleep 1
repo=$(cat <<EOF
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
)
if grep -Fxq "$repo" /etc/pacman.conf; then
    printf "repo already present\n"
else
    printf "adding-repo\n"
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && sudo pacman-key --lsign-key 3056513887B78AEB && sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm --needed
    sudo tee -a /etc/pacman.conf <<< "$repo"
fi
sleep 1
clear

printf "# pacman-tweaks\n"
sleep 0.5
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
printf "done\n"
sleep 1
clear

printf "# installing packages"
sleep 0.5
curl -sO "https://codeberg.org/polarhive/dots/raw/branch/main/pkglist.txt"
sudo pacman -Syyu --needed --noconfirm - < pkglist.txt
rm pkglist.txt
printf "done\n"
sleep 1
clear

printf "# dotfiles\n"
sleep 0.5
git clone https://github.com/zsh-users/zsh-autosuggestions.git --depth=1 ~/.local/share/zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git --depth=1 ~/.local/share/zsh/zsh-syntax-highlighting
git clone https://codeberg.org/polarhive/dots.git --depth=1 ~/.cache/arch/dots
cp -r ~/.cache/arch/dots/.config ~/
cp -r ~/.cache/arch/dots/.local ~/
rm -rf ~/.cache/arch
sleep 1
clear

printf "# changing shell\n"
sleep 0.5
chsh -s $(which zsh)
sleep 1
clear
zdot="export ZDOTDIR=/home/$(whoami)/.config/zsh"
if grep -Fxq "$zdot" /etc/environment; then
    printf "ZDOT variable already present\n"
else
    printf "adding ZDOT variable\n"
    sudo tee -a /etc/environment <<< "$zdot"
fi
sleep 1
clear

printf "# setting gtk theme"
sleep 0.5
clear
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
#gsettings set org.gnome.desktop.interface document-font-name 'Product Sans 12'
#gsettings set org.gnome.desktop.interface font-name 'Product Sans,  10'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Semi-Bold 10'
clear

printf "# done\n"
sleep 0.5
clear
printf "# rebooting in: 3...\n"
sleep 1
clear
printf "# rebooting in: 2..\n"
sleep 1
clear
printf "# rebooting in: 1.\n"
sleep 1
clear
reboot
