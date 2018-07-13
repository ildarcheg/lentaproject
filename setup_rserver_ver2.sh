# INSTALL r server
sudo nano /etc/apt/sources.list
# add:
# deb https://cloud.r-project.org/bin/linux/ubuntu xenial/
sudo apt-get update
sudo apt-get install r-base
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.453-amd64.deb
sudo gdebi rstudio-server-1.1.453-amd64.deb
# check http://<server-ip>:8787
sudo rstudio-server verify-installation

# INSTALL packages
sudo apt-get install libcurl4-openssl-dev libssl-dev libxml2-dev libsasl2-dev
Rscript -e "install.packages(c('lubridate', 'rvest', 'dplyr', 'tidyr', 'purrr', 'XML', 'data.table', 'stringr', 'jsonlite', 'reshape2', 'tibble', 'tm', 'ggplot2', 'gridExtra', 'rmarkdown'))"

# INSTALL mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# INSTALL sysstat
sudo apt-get install sysstat
sudo nano /etc/default/sysstat # set as TRUE

cd && wget https://raw.githubusercontent.com/hotice/webupd8/master/install-google-fonts
chmod +x install-google-fonts
./install-google-fonts