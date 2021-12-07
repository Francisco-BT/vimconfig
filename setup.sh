echo "Instaling git..."
sudo apt install git

echo "Installig zsh..."
sudo apt install zsh

echo "Set up zsh as default terminal"
chsh -s `which zsh`

echo "Make sure the system has curl"
sudo apt install curl

echo "Make sure kitty is installed"
sudo apt install kitty

echo "Installing neovim"
sudo apt install neovim

echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Adding zsh plugins"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

echo "Adding fzf to search files"
echo "You can search files using Ctrl + T"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


echo "\n Set up vim and zsh config"
cp .vimrc ~/.vimrc
cp .zshrc ~/.zshrc
cp .tmux.conf ~/.tmux.conf

mkdir ~/.vim
cp -r ftplugin ~/.vim
cp -r plugin ~/.vim

cd ..

echo "Reload zsh config"
source ~/.zshrc

echo "Installing yarn"
npm install --global yarn

echo "Setup vimplug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Run :PlugInstall when you executed vim"
echo "Add git utils alias"
git config --global alias.st status
git config --global alias.ps push
git config --global alias.ch checkout
git config --global alias.pl pull
git config --global alias.cm commit

echo "Creating confguration between vim and neovim"

mkdir -p ~/.config/nvim
touch ~/.config/nvim/init.vim

echo "Creating configuration to kitty"
mkdir -p ~/.config/kitty
cp ./kitty.conf ~/.config/kitty/

cat /dev/null > ~/.config/nvim/init.vim
echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" >> ~/.config/nvim/init.vim
echo "let &packpath=&runtimepath" >> ~/.config/nvim/init.vim
echo "source ~/.vimrc" >> ~/.config/nvim/init.vim


echo "Setup TMUX plugins"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

echo "Script ended"


