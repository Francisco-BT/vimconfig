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
git clone https://github.com/Francisco-BT/vimconfig.git

cd vimconfig 
cp .vimrc ~/.vimrc
cp .zsrhc ~/.zsrhc
cp .tmux.conf ~/.tmux.conf

mkdir ~/.vim
cp -r ftplugin ~/.vim
cp -r plugin ~/.vim

cd ..

echo "Installing yarn"
sudo npm install --global yarn

echo "Setup vimplug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/mast

echo "Finished setup. You can use https://github.com/denysdovhan/spaceship-prompt as your oh-my-zsh theme"
echo "Run :PlugInstall when you executed vim"

echo "Add git utils alias"
git config --global alias.st status
git config --global alias.ps push
git config --global alias.ch checkout

echo "Script ended"
