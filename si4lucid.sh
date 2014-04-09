sudo apt-get purge '^openoffice.org-.*' -y
sudo apt-get purge ubuntuone-client -y
sudo apt-get purge totem -y
sudo apt-get purge rhythmbox -y
sudo apt-get purge empathy -y
sudo apt-get purge firefox -y
sudo apt-get purge ibus -y

echo "添加 mercurial 仓库..."
sudo add-apt-repository  ppa:mercurial-ppa/releases
echo "添加 tortoisehg 仓库..."
sudo add-apt-repository  ppa:tortoisehg-ppa/releases
echo "添加openjdk 仓库 ..."
sudo add-apt-repository  ppa:openjdk/ppa
echo "add git-core repository ..."
sudo add-apt-repository  ppa:git-core/ppa
echo "add shutter ppa ..."
sudo add-apt-repository ppa:shutter/ppa 
echo "add synapse ppa ..."
sudo add-apt-repository ppa:synapse-core/ppa
echo "add fcitx ppa..."
sudo apt-add-repository ppa:fcitx-team/nightly

echo "更新源...."
sudo apt-get update

echo "安装和配置 git svn等版本管理工具...."
sleep 3
sudo apt-get install git-core gitk git-gui git-svn -y
sudo apt-get install apache2 libapache2-svn subversion -y
git config --global user.name "tracyone"
git config --global user.email "tracyone@live.cn"
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=86400'
git config --global core.editor vim

echo "安装java和java运行环境..."
sleep 3
sudo apt-get install openjdk-7-jdk -y

echo "安装goagent..."
sleep 3
git clone https://github.com/goagent/goagent ./goagent
sudo rm -rf /opt/goagent 
sudo cp -a ./goagent /opt
sudo chown -R $(whoami) /opt/goagent
sudo chgrp -R $(whoami) /opt/goagent
sudo apt-get -y install python-vte
echo "配置goagent..."
sleep 3
python /opt/goagent/server/uploader.zip
sudo sed -ie 's/^appid.*/appid = tracyone1989|tracyone1990/' /opt/goagent/local/proxy.ini
echo "开机启动goagent..."
sleep 3
sudo echo "python /opt/goagent/local/proxy.py" | sudo tee -a /etc/init.d/rc.local


echo "安装CodeBlock..."
sleep 3
sudo apt-get install codeblocks g++ wx-common libwxgtk2.8-0 build-essential  wxformbuilder codeblocks-dbg codeblocks-contrib wx2.8-headers  wx2.8-i18n -y

echo "安装 pidgin ... "
sleep 3
sudo apt-get install libpurple0 pidgin

echo "安装nautils相关..."
sleep 3
sudo apt-get  install nautilus-open-terminal nautilus-actions -y

echo "安装其它杂七杂八.."
sleep 3
sudo apt-get  install mercurial python-nautilus tortoisehg -y
sudo apt-get  install unrar p7zip-full zhcon wmctrl -y
sudo apt-get install vlc -y
sudo apt-get install shutter -y
sudo apt-get install synapse -y
sudo apt-get install fcitx fcitx-googlepinyin -y

echo "嵌入式开发.."
sudo apt-get install putty -y
sudo apt-get install samba4 smbfs system-config-samba -y
sudo apt-get install openbsd-inetd tftp-hpa tftpd-hpa -y
sudo apt-get install nfs-kernel-server -y

if [[ ! -d "linux-config" ]];then
   git clone https://github.com/tracyone/linux-config 
fi
sudo ln -s /usr/bin/make /usr/bin/gmake
sudo cp ./linux-config/*.desktop /usr/share/applications/

echo "安装oh my zsh..."
rm -rf ~/.oh-my-zsh
sudo apt-get install zsh -y
wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
echo "修改当前用户默认shell为zsh..."
echo "待补充暂时不知道如何实现..."
echo "恢复.zshrc"
cp ./linux-config/.zshrc ~

echo "Install adobe flash player for firefox ..."

mkdir si_temp
if [[ ! -f "install_flash_player_11_linux.i386.tar.gz" ]];then
   wget --no-check-certificate http://fpdownload.macromedia.com/get/flashplayer/pdc/11.2.202.350/install_flash_player_11_linux.i386.tar.gz
fi
tar -xvf install_flash_player_11_linux.i386.tar.gz -C ./si_temp
sudo cp -a si_temp/libflashplayer.so /usr/lib/mozilla/plugins
sudo cp -a si_temp/usr/* /usr
rm -rf ./si_temp/

echo "安装字体...需要很长时间请耐心等待..."
if [[ ! -d "program_font" ]];then
   git clone https://github.com/tracyone/program_font
fi
sudo chmod -R a+x program_font/*
sudo mkdir -p /usr/share/fonts/MyFonts
mkdir ~/.fonts/
cp ./program_font/* ~/.fonts/
sudo cp ./program_font/* /usr/share/fonts/MyFonts
sudo fc-cache -f -v

echo "编译安装最新版本的gvim..."
echo "安装编译gvim所需的依赖.."
sudo apt-get build-dep vim -y
sudo apt-get install lua5.1 liblua5.1-dev -y
if [[ ! -d "vim-src" ]];then
	echo "Fetch vim source code from googlecode by hg version control tool"
	hg clone https://vim.googlecode.com/hg/ vim-src
else
	echo "Found vim source directory in current directory.."
    cd vim-src
    hg pull
    hg update
fi
which gvim
if [[ $? -eq 0 ]]; then
	echo "GVim has been installed in your computer .."
else
	echo "Now we will build GVim and install it to you local computer ..."
	cd vim-src/src
	sudo make uninstall
	make clean
	sudo rm -rf ./auto/config.cache
	./configure --with-x \
		--with-features=huge \
		--enable-luainterp=dynamic \
		--enable-perlinterp=dynamic \
		--enable-pythoninterp=dynamic \
		--enable-tclinterp \
		--enable-rubyinterp=dynamic \
		--enable-gui=auto \
		--enable-cscope \
		--enable-multibyte \
		--enable-fontset \
		--disable-smack \
		--enable-fail-if-missing \
		--with-compiledby=tracyone@live.cn
	if [[ $? -eq 0 ]];then
		make && sudo make install
	fi
	cd -
	sudo echo "Defaults		always_set_home" | sudo tee -a /etc/sudoers
	echo "Install pyclewn .."
fi


echo "清除工作...."
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo apt-get clean
echo "温馨提示：电脑将在30分钟后关机.."
sudo shutdown -h 30


