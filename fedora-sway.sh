#!/bin/bash

# DNF config
echo "max_parallel_downloads=20
defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf

sudo dnf clean all

# install Rpmfusion repo
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

# enable COPRs
sudo dnf copr enable -y atim/bottom
sudo dnf copr enable -y atim/lazygit
sudo dnf copr enable -y varlad/helix
sudo dnf copr enable -y tokariew/glow

sudo dnf upgrade -y --refresh

# grab all packages to install from repos
sudo dnf install $(cat fedora.repopackages) -y

# grab all packages to install from flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub $(cat fedora.flatpackages) -y

# compile and install Cargo packages
echo "export PATH='/home/$USER/.cargo/bin'" >> cargo.sh && sudo mv ./cargo.sh /etc/profile.d/
cargo install $(cat fedora.cargopackages)


# alacritty theme changer
sudo npm i -g alacritty-themes

# sway autotiling
sudo pip install autotiling

# Make zsh the default shell
chsh -s /usr/bin/zsh
# Get oh-my-zsh and install it
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Get spaceship theme and install it
curl -o - https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/install.zsh | zsh

# Add basic spaceship config to the end of .zshrc
cat >> $HOME/.zshrc <<EOL 
SPACESHIP_PROMPT_ORDER=(
  time          # Time stampts section
  user          # Username section
  host          # Hostname section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  node          # Node.js section
  rust          # Rust section
  docker        # Docker section
  venv          # virtualenv section
  conda         # conda virtualenv section
  pyenv         # Pyenv section
  exec_time     # Execution time
  line_sep      # Line break
  vi_mode       # Vi-mode indicator
  jobs          # Backgound jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

# TIME
SPACESHIP_TIME_SHOW=true
# EXIT CODE
SPACESHIP_EXIT_CODE_SHOW=true
EOL

# setup dotfiles
echo "Intalling Chezmoi"
sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b $HOME/.local/bin
chezmoi init --apply https://github.com/alarawms/dotfiles.git

# font setup
if [[ -d ~/.local/share/fonts/ ]]
then
  echo "Downloading terminal font"
else
  mkdir -vp ~/.local/share/fonts/
fi

cd
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/CascadiaCode.zip
unzip CascadiaCode.zip -d ~/.local/share/fonts/
rm CascadiaCode.zip



#install doom emacs 
echo "install ing doom emacs"
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
