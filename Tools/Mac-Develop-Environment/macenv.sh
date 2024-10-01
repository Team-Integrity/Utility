#!/bin/bash

set -e

# Prompt user to agree to the license agreement
read -p "Do you agree to the terms of the license agreement? (Y/N): " agreed
if [ "$agreed" != "Y" ]; then
    echo "You did not agree to the license. Exiting."
    exit 1
fi

# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Rosetta for Apple silicon
softwareupdate --install-rosetta

# Switch Xcode path and accept the license
sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
sudo xcodebuild -license
xcodebuild -downloadAllPlatforms

# Install packages listed in requirements.txt
if [ -f "requirements.txt" ]; then
    echo "Installing dependencies listed in requirements.txt..."
    while read requirement; do
        pip3 install -r requirements.txt
    done < requirements.txt
    echo "Dependencies installed successfully."
else
    echo "requirements.txt not found. No dependencies to install."
fi

# Update Homebrew and install dependencies
xargs brew install < brew-requirements.txt
brew update
brew cask upgrade

if [ -f "brew-cask-requirements.txt" ]; then
    echo "Installing dependencies listed in npm-requirements.txt..."
    while read requirement; do
        brew install --cask $requirement
    done < npm-requirements.txt
    echo "Dependencies installed successfully."
else
    echo "npm-requirements.txt not found. No dependencies to install."
fi

# Update MacPorts and install dependencies
curl -O https://distfiles.macports.org/MacPorts/MacPorts-2.10.1.tar.bz2
tar xf MacPorts-2.10.1.tar.bz2
cd MacPorts-2.10.1/
./configure
make
sudo make install
sudo port -v selfupdate

# Configure Git
read -p "Enter your Git username: " username
read -p "Enter your Git email address: " email
git config --global user.name "$username"
git config --global user.email "$email"
echo "Git username set to: $username"
echo "Git email address set to: $email"

# Install necessary Git repositories
curl -s "https://raw.githubusercontent.com/superhj1987/awesome-mac-things/master/get.sh" | bash -s
cd ..
mkdir Devloper
cd Devloper
mkdir environment
git clone https://github.com/oobabooga/text-generation-webui.git
git clone https://github.com/chidiwilliams/GPT-Automator.git
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd ..
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
ollama pull llama3.2

# Install RVM and NVM
curl -L https://get.rvm.io | bash -s stable --ruby
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install node
nvm use node

npm install -g coffee-script
npm install -g grunt-cli
npm install -g gulp
npm install -g bower
npm install -g jshint
npm install -g less

# Download specific Gitignore and Gitconfig files
curl "https://raw.githubusercontent.com/flatiron-school/dotfiles/master/ubuntu-gitignore" -o "$HOME/.gitignore"
curl "https://raw.githubusercontent.com/flatiron-school/dotfiles/master/gitconfig" -o "$HOME/.gitconfig"

# Run setup validation script
curl -so- https://raw.githubusercontent.com/learn-co-curriculum/flatiron-manual-setup-validator/master/manual-setup-check.sh | bash 2> /dev/null

# Other tool installations
curl https://pyenv.run | bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Setup Node.js and related tools
nvm install v16.13.2
nvm install node

if [ -f "npm-requirements.txt" ]; then
    echo "Installing dependencies listed in npm-requirements.txt..."
    while read requirement; do
        npm install $requirement
    done < npm-requirements.txt
    echo "Dependencies installed successfully."
else
    echo "npm-requirements.txt not found. No dependencies to install."
fi

if [ -f "npm-g-requirements.txt" ]; then
    echo "Installing dependencies listed in npm-requirements.txt..."
    while read requirement; do
        npm install -g $requirement
    done < npm-requirements.txt
    echo "Dependencies installed successfully."
else
    echo "npm-requirements.txt not found. No dependencies to install."
fi

# Install necessary Ruby gems
gem install pg
gem install cocoapods
gem update --system

if [ -f "gem-requirements.txt" ]; then
    echo "Installing dependencies listed in gem-requirements.txt..."
    while read requirement; do
        gem install $requirement
    done < gem-requirements.txt
    echo "Dependencies installed successfully."
else
    echo "gem-requirements.txt not found. No dependencies to install."
fi

# Setup Composer for PHP
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

# Update shell configuration
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> ~/.zshrc
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo 'export PATH="/opt/homebrew/opt/php@8.0/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="/opt/homebrew/opt/php@8.0/sbin:$PATH"' >> ~/.zshrc
export LDFLAGS="-L/opt/homebrew/opt/php@8.0/lib"
export CPPFLAGS="-I/opt/homebrew/opt/php@8.0/include"
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.bash_profile
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Source the updated shell configuration
source ~/.zshrc

cd ~/.
python3 -m venv pip_venv
source env/bin/activate

# Prompt user to run the doctor script
read -p "Do you want to run the doctor? (Y/N): " agreed
if [ "$agreed" = "Y" ]; then
    bash macenv-doctor.sh
else
    echo "You did not agree to run the doctor. Exiting."
    exit 1
fi
