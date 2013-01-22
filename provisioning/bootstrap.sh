#!/bin/sh

# Bootstrap script to configure a Vagrant base box.

##################################

HOSTNAME="vagrant-centos63"
DOMAIN="vagrantup.com"
USERNAME="vagrant"
PASSWORD="vagrant"

##################################
# Print some information on how the machine is bootstrapped
##################################

echo "Bootstrapping the CentOS 6.3 base box:"
echo "Hostname: ${HOSTNAME}"
echo "Domain: ${DOMAIN}"
echo "Username: ${USERNAME}"
echo "Password: ${PASSWORD}"

##################################
# Hostname configuration
##################################

if [ $(cat /etc/hosts | grep "Vagrant bootstrap script!" | wc -l) -eq 0 ]; then 

  echo
  echo "Configure hostname ..."
  echo -e "# Hostname configured by Vagrant bootstrap script!\n# Do not remove these comments to prevent the bootstrap script from overwriting this file.\n127.0.0.1 localhost ${HOSTNAME}" > /etc/hosts
  echo -e "NETWORKING=yes\nHOSTNAME=${HOSTNAME}" > /etc/sysconfig/network
  hostname ${HOSTNAME}

fi

##################################
# SELinux configuration
##################################

if [ $(cat /etc/sysconfig/selinux | grep SELINUX=disabled | wc -l) -eq 0 ]; then 

  echo
  echo "Disable SELinux ..." 

  cat > /etc/sysconfig/selinux << "EOF"
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
# enforcing - SELinux security policy is enforced.
# permissive - SELinux prints warnings instead of enforcing.
# disabled - SELinux is fully disabled.
SELINUX=disabled
# SELINUXTYPE= type of policy in use. Possible values are:
# targeted - Only targeted network daemons are protected.
# strict - Full SELinux protection.
SELINUXTYPE=targeted

EOF

fi

##################################
# Puppet configuration
##################################

# Add the puppet Yum repository
if [ ! -f /etc/yum.repos.d/puppet.repo ]; then
	
	echo
	echo "Setup the Puppet Labs YUM repo ..." 

	cat > /etc/yum.repos.d/puppet.repo << "EOF"
[puppetlabs]
name=Puppet Labs Packages
baseurl=http://yum.puppetlabs.com/el/$releasever/products/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
EOF

fi

# Install puppet if not installed
if [ $(rpm -q puppet --nodigest --nosignature | grep "not installed" | wc -l) -eq 1 ]; then	
	echo
	echo "Install puppet ..."
	yum -y install puppet
fi

# Install or update puppet modules e.g. PUPPET_MODULES=( puppetlabs-stdlib puppetlabs-firewall )
PUPPET_MODULES=( )
PUPPET_MODULE_LIST=$(puppet module list)

for mod in "${PUPPET_MODULES[@]}" 
do
  if [ $(echo $PUPPET_MODULE_LIST | grep $mod | wc -l) -eq 0 ]; then
    echo "Installing puppet module: $mod"
    puppet module install $mod --module_repository http://forge.puppetlabs.com
  #else
    # echo "Trying to upgrading puppet module: $mod"
    # puppet module upgrade $mod --module_repository http://forge.puppetlabs.com
  fi
done

# Create a pre-package script to be used before repackaging the box
if [ ! -f /root/pre-package.sh ]; then
  
  echo
  echo "Creating pre-package script ..." 
  cat > /root/pre-package.sh << "EOF"
#!/bin/bash

# Cleanup yum cache
yum clean all

# Cleanup logs
find /var/log -type f -mtime +1 -exec rm '{}' \;
> /var/log/audit/audit.log
> /var/log/boot.log
> /var/log/btmp
> /var/log/cron
> /var/log/dmesg
> /var/log/dracut.log
> /var/log/lastlog
> /var/log/maillog
> /var/log/messages
> /var/log/secure
> /var/log/yum.log

# Clean up bash history
> /home/vagrant/.bash_history
> /root/.bash_history

# Do not install gem documentation (--no-rdoc --no-ri) or delete any documentation here if already installed
rm -rf "$(gem env gemdir)"/doc/*
EOF

  chmod +x /root/pre-package.sh
fi
