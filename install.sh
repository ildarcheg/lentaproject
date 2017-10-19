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

message "ALL DONE"