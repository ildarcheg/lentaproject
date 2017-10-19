#Echo delimiter
function delimiter() {
	echo -e "\n---------------------------\n"
}

# Echo message
function message() {
	delimiter
	echo $1
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
yes | sudo gdebi rstudio-server-1.1.383-amd64.deb -y

#message "Install Apache"
#sudo apt-get --yes --force-yes install apache2

message "Install MongoDB"
wget http://launchpadlibrarian.net/293727143/libc6_2.23-0ubuntu5_amd64.deb
yes | sudo gdebi libc6_2.23-0ubuntu5_amd64.deb -y

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
sudo echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/testing multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt-get update -y
sudo apt-get install -y mongodb-org

sudo service mongod start
cat /var/log/mongodb/mongod.log

message "Install openssl"
#sudo apt-get install libssl-dev libcurl4-openssl-dev libsasl2-dev
sudo apt-get install -y libssl-dev libsasl2-dev libcurl4-openssl-dev

#sudo echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee -a /etc/apt/sources.list.d/webupd8team-java.list
#sudo echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/webupd8team-java.list
#apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
#apt-get update
#apt-get install oracle-java8-installer

#sudo echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/webupd8team-java.list
#echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
#echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list



message "ALL DONE"