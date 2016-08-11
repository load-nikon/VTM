#!/bin/bash
# scan agent deployment

# The following comment block will guide you through the deployment of a fresh install of Kali Linux from the vSphere client window.
: <<'vSphere_and_Kali_installer_instructions' # This will comment out the following section.  Humans: ignore the next instance of this phrase.
In vSphere, Create New Virtual Machine.
Configuration
	Select Custom.
	Click Next.
Name and Location
	Name the machine "Orbital (Logical Group) 129".
	Click Next.
Resource Pool (may not apply)
	Select appropriate pool.
	Click Next.
Storage
	Select the appropriate datastore.
	Click Next.
Virtual Machine Version
	Select the latest VM Version available.
	Click Next.
Guest Operating System
	Select Linux.
	For version, select "Debian GNU/Linux 6 (64-bit)".
	Click Next.
CPUs
	Increase number of cores per virtual socket to 2.
	Click Next.
Memory
	On the sliding scale, click 16 GB.
	Click Next.
Network
	For NIC 1, change adapter type to VMXNET 3.
	Click Next.
SCSI Controller
	Ensure "LSI Logic Parallel" is selected.
	Click Next.
Select a Disk
	Ensure "Create a new virtual disk" is selected.
	Click Next.
	Change Disk Size to 80 GB.
	Click Next.
Advanced Options
	Click Next.
Ready to Complete
	Click Finish
Power on the Virtual Machine and open a console.  Machine will fail to boot.
Console Window
	Select the CD Icon > CD/DVD Drive 1 > Connect to ISO image on a datastore
	Select appropriate datastore
	Select ISO image.
	Click OK
Click inside of VM console area to capture HID
Press spacebar.  Machine will reboot.
Grub Boot Loader
	Select "Install"
	Press Enter
Kali Installer
	Select a language
		Select English
		Press Enter
	Select your location
		Select United States
		Press Enter
	Configure the keyboard
		Select American English
		Press Enter
	Configure the network
		Network autoconfiguration may fail.  If it does, follow this guide.
		Press Enter
		Select Configure network manually
		Press Enter
		Enter first 3 octets of IP address in accordance with desired network.  The last octet shall be 129.
		Press Enter
		For netmask, unless explicitly told otherwise, leave at 255.255.255.0
		Press Enter
		For Gateway, leave as default
		Press Enter
		For Name server addresses, leave the default and type "[Space]8.8.8.8[Space]208.67.222.222"
		Press Enter
		For Hostname, Enter "Orbital(LogicalGroup)" with no spaces.
		Press Enter
		For Domain name, do not enter anything.
		Press Enter
	Set up users and passwords
		For Root Password, enter that one horrible password until we come up with a better standard.
		Press Enter
		Enter it again
		Press Enter
	Configure the clock
		Select Eastern time zone
		Press Enter
	Partition Disks
		Select "Guided - use entire disk"
		Press Enter
		Select thathe single available disk to partition.  It should be something like "SCSI3 (0,0,0) (sda) - 85.9 GB VMware Virtual disk"
		Press Enter
		For Partitioning scheme, select "All files in one partition"
		Press Enter
		For the overview, accept and select "Finish partitioning and write changes to disk"
		Press Enter
		For final confirmation, select Yes
		Press Enter
	Configure the package manager
		Select yes to use a network mirror
		Press Enter
		Do not enter a network proxy
		Press Enter
	Install the GRUB Boot loader on a hard disk
		Select Yes to install GRUB boot loader to the master boot record
		Press Enter
		Select /dev/sda for boot loader installation
		Press Enter
	Finish the installation
		Press Enter
Kali Linux
	Log in as root
	Open a terminal window and proceed with the code section below
vSphere_and_Kali_installer_instructions


# Start screen for logging
screen -L
# Update repository list and upgrade all installed packages
apt-get update && apt-get upgrade -y
	# Get some coffee
	# An apt information prompt will describe certian critical upgrades.  You may press q.
	# sslh configuration
		# Select to run sslh as standalone and press Enter.
	# Configuring libc6:amd64
		# Select Yes to restart services during package upgrades without asking and press Enter.
	# Get some coffee
# Upgrade distro to current release (is that right?)
apt-get dist-upgrade -y
	# Configuring wireshark-common
		# Select yes so that non-superusers can capture packets and press Enter.
# Install requisite software
apt-get install -y openssh-server openvas tmux htop
# Allow secure ssh login by clearing default keys and making daemon start on boot.
update-rc.d -f ssh remove
update-rc.d -f ssh defaults
cd /etc/ssh/
mkdir insecure_original_default_kali_keys
mv ssh_host_* insecure_original_default_kali_keys
dpkg-reconfigure openssh-server
service ssh restart
update-rc.d -f ssh enable 2 3 4 5
# Create new user with sudo privledges so we don't have to log in as root ever again.
useradd -m openvas
passwd openvas
	# thatonepassword+"openvas"
# read -s -p "Please enter that one horrible passphrase"
usermod -a -G sudo openvas
chsh -s /bin/bash openvas
# Set up openvas.
openvas-setup
	# The setup process will end with a line that says "User created with password..." followed by the default admin password in single quotes.  Copy everything between the single quotes.

# Open a new Firefox session and navigate to https:\\localhost:9392
	# Click Advanced then Add Exception, then select Confirm Security Exception
	# Login with credentials admin and paste the password you just copied.
	# Navigate to the Users page, found under the Administration Menu
	# Click the wrench in the Actions column for the row corresponding to username Admin
	# Select the password field and type that awful root password and add the phrase openvas without ANY spaces, then click "Save User"
	# Click "Logout" in the upper right corner, then confirm access by logging in with the new credentials.
	# Log out of Greenbone Security Assistant, close Firefox, and return to the terminal.

# Make Greenbone listen on external interface.
cd /lib/systemd/system
sed -e 's/127.0.0.1/0.0.0.0/g' greenbone-security-assistant.service openvas-manager.service openvas-scanner.service -i
systemctl daemon-reload
systemctl restart greenbone-security-assistant.service openvas-manager.service openvas-scanner.service
# Copy the IP address of the machine.  It is listed under eth0, next to inet and will be the IPv4 address you chose earlier.
ip a
# Test this by returning to your local desktop session, opening a browser, navigating to https:\\(the IP address you copied):9392.  You should see the GSA login page.
# Exit screen and close terminal.
exit
exit
# Log out as root and close the vMware console.
EOF
