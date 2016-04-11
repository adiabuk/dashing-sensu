pkill ruby2.1
su -c 'nohup bundle exec thin start -R config.ru -e development -p 8080 0<&- &>> /vagrant/fleximon.log &' vagrant
