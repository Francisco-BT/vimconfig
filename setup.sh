echo "Instaling git..."
sudo apt install git

echo "Installig zsh..."
sudo apt-get install zsh

echo "Set up zsh as default terminal"
chsh -s `which zsh`

echo "Make sure the system has curl"
sudo apt install curl

echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Add to you .zsrhc file"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "Add \"zsh-autosuggestions\" to your .zshrc file"

git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
echo "Add zsh-nvm on your .zshrc"

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

echo "You can search files using Ctrl + T"
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


echo "Finished setup. You can use https://github.com/denysdovhan/spaceship-prompt as your oh-my-zsh theme"
echo "Run :PlugInstall when you executed vim"

echo "Add git utils alias"
git config --global alias.st status
git config --global alias.ps push
git config --global alias.ch checkout
git config --global alias.pl pull

echo "Installing neovim"
sudo apt install neovim

echo "Creating confguration between vim and neovim"

mkdir -p ~/.config/nvim
touch ~/.config/nvim/init.vim

cat /dev/null > ~/.config/nvim/init.vim
echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" >> ~/.config/nvim/init.vim
echo "let &packpath=&runtimepath" >> ~/.config/nvim/init.vim
echo "source ~/.vimrc" >> ~/.config/nvim/init.vim


echo "Setup TMUX plugins"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

echo "Script ended"


