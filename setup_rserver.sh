#Echo delimiter
function delimiter() {
	echo -e "\n---------------------------\n"
}

# Echo message
function message() {
	delimiter
	echo $1
	echo $1 >> install.log
	delimiter
}

# Check if $1 service is up and running
# If servise is down the script will stop
function check_service_stat() {
	service $1 status | grep "Active: active" | grep -v grep > /dev/null
	if [ $? != 0 ]; then
		echo "ERROR: $1 service is NOT running!!!"
		exit 1;
	else
		echo "$1 service is up and running"
 	fi;	
}

#Exit on error
set -e

# INSTALL TOOLS
message "Set up the environment"

message "Update packages"
cd
sudo apt-get update -y
sudo apt-get upgrade -y

message "Install R"
sudo echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | sudo tee -a /etc/apt/sources.list
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install r-base r-base-dev -y

message "Install gdebi-core"
sudo apt-get install gdebi-core -y

message "Install RStudio"
wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb
yes | sudo gdebi rstudio-server-1.1.383-amd64.deb
rm rstudio-server-1.1.383-amd64.deb
check_service_stat "rstudio-server"

#message "Install Apache"
#sudo apt-get --yes --force-yes install apache2

message "Install MongoDB"
wget http://launchpadlibrarian.net/293727143/libc6_2.23-0ubuntu5_amd64.deb
yes | sudo gdebi libc6_2.23-0ubuntu5_amd64.deb 
rm libc6_2.23-0ubuntu5_amd64.deb 

sudo sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 
sudo echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
sudo apt-get update -y
sudo apt-get install -y mongodb-org

sudo service mongod start
sudo systemctl enable mongod
cat /var/log/mongodb/mongod.log
check_service_stat "rmongod"

message "Install libraties"
sudo apt-get install -y libssl-dev libsasl2-dev libcurl4-openssl-dev libpq-dev libxml2-dev

#message "Install PostgreSQL"
#sudo apt-get update -y
#sudo apt-get install -y postgresql postgresql-contrib
#sudo -u postgres createuser --interactive
#sudo -u postgres createdb ildar

sudo ufw allow 234
sudo ufw allow 8787
sudo ufw enable
sudo systemctl enable ufw

sudo setfacl -m u:ildar:rwx /etc/crontab
sudo setfacl -x u:ildar /etc/crontab
sudo getfacl /etc/crontab 

sudo apt-get install sysstat
sudo vi /etc/default/sysstat 		# set enable=true
sudo nano /etc/cron.d/sysstat 

#PATH=/usr/lib/sysstat:/usr/sbin:/usr/sbin:/usr/bin:/sbin:/bin
## Activity reports every 10 minutes everyday
#* * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1
## Additional run at 23:59 to rotate the statistics file
#59 23 * * * root command -v debian-sa1 > /dev/null && debian-sa1 60 2
sudo service sysstat restart

# sudo echo '/usr/sbin/ufw enable' | sudo tee /etc/rc.local

# sudo echo 'install.packages("memoise")' | sudo tee install_packages.R
# sudo echo 'require(memoise)' | sudo tee load_packages.R
# sudo echo 'install.packages("devtools")' | sudo tee -a install_packages.R
# sudo echo 'require(devtools)' | sudo tee -a install_packages.R
# sudo echo 'require(devtools)' | sudo tee -a load_packages.R
# sudo echo 'devtools::install_github("jayjacobs/tldextract")' | sudo tee -a install_packages.R
# sudo echo 'require(tldextract)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("mongolite")' | sudo tee -a install_packages.R
# sudo echo 'require(mongolite)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("lubridate")' | sudo tee -a install_packages.R
# sudo echo 'require(lubridate)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("rvest")' | sudo tee -a install_packages.R
# sudo echo 'require(rvest)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("dplyr")' | sudo tee -a install_packages.R
# sudo echo 'require(dplyr)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("tibble")' | sudo tee -a install_packages.R
# sudo echo 'require(tibble)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("tidyr")' | sudo tee -a install_packages.R
# sudo echo 'require(tidyr)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("data.table")' | sudo tee -a install_packages.R
# sudo echo 'require(data.table)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("stringr")' | sudo tee -a install_packages.R
# sudo echo 'require(stringr)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("tm")' | sudo tee -a install_packages.R
# sudo echo 'require(tm)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("ggplot2")' | sudo tee -a install_packages.R
# sudo echo 'require(ggplot2)' | sudo tee -a load_packages.R
# sudo echo 'install.packages("gridExtra")' | sudo tee -a install_packages.R
# sudo echo 'require(gridExtra)' | sudo tee -a load_packages.R

Rscript -e "install.packages(c('lubridate', 'rvest', 'dplyr', 'tidyr', 'purrr', 'XML', 'data.table', 'stringr', 'jsonlite', 'reshape2', 'tibble', 'tm', 'ggplot2', 'gridExtra', 'rmarkdown'))"

cd && wget https://raw.githubusercontent.com/hotice/webupd8/master/install-google-fonts
chmod +x install-google-fonts
./install-google-fonts

#wget http://download.cdn.yandex.net/mystem/mystem-3.0-linux3.1-64bit.tar.gz
#tar -xvzf mystem-3.0-linux3.1-64bit.tar.gz
#rm mystem-3.0-linux3.1-64bit.tar.gz



#sudo echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee -a /etc/apt/sources.list.d/webupd8team-java.list
#sudo echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/webupd8team-java.list
#apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
#apt-get update
#apt-get install oracle-java8-installer

#sudo echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/webupd8team-java.list
#echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
#echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list



message "ALL DONE"