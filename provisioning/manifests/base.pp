class motd {

  group { "puppet":
    ensure => "present",
  }

  File { owner => 0, group => 0, mode => 0644 }
  
  file { '/etc/motd':
    content => "Welcome to your Vagrant-built, puppet provisioned virtual machine!\n"
  }

}

include motd
