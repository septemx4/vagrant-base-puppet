vagrant-base-puppet
===================

For building a Vagrant base box with Puppet

How to use
---------

 - Bootstrap the minimal Vagrant box:
   ```
   vagrant up
   ```
 - (Re)package the bootstrapped minimal box as a (golden) base box: 
  ```
  vagrant package --vagrantfile Vagrantfile.pkg
  ```
  
