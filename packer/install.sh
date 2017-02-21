#!/bin/bash -x
# for Ubuntu 14.04

sudo su
set -e
set -u
cd
sudo apt-get -qq -y update
sudo apt-get -qq -y install git zsh build-essential libssl-dev libreadline-dev zlib1g-dev libpq-dev tree nginx unzip libmysqlclient-dev
echo -e "Host github.com\nIdentityFile ~/.ssh/kuina_deployer\nStrictHostKeyChecking no\nUserKnownHostsFile=/dev/null" >> .ssh/config
# copy kuina_deployer* to the machine somehow (manually/packer)
chmod 0600 ~/.ssh/kuina_deployer*
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
source ~/.profile
rbenv install 2.4.0
rbenv global 2.4.0
gem update --system
gem install bundler
git clone git@github.com:estiu/kuina.git -b master kuina
cd kuina
bundle --without development test --path vendor/bundle # extraneous GEM_HOME insists in being there under Codeship, so we install to ~/kuina/vendor/bundler
cd
echo 'staging' > ~/kuina/RAILS_ENV
# copy .env to ~/kuina
cd kuina
cp packer/kuina_unicorn /etc/init.d # controllable with: sudo service kuina_unicorn stop/start
chmod 755 /etc/init.d/kuina_unicorn
update-rc.d kuina_unicorn defaults
rm -f /etc/nginx/sites-enabled/default
cp packer/kuina_nginx /etc/nginx/sites-enabled/default
sed -ie 's/www-data/root/g' /etc/nginx/nginx.conf
service nginx restart
