class ntp {

    package { ntp: 
        ensure => installed
    }

    service { ntpd:
        ensure => running,
        path => "/etc/init.d/ntpd",
        subscribe => [ Package["ntp"], File["ntp.conf"] ]
    }
    
    file { "ntp.conf":
        path => "/etc/ntp.conf",
        ensure => present,
        owner => root,
        group => root,
        mode => 644,
        require => Package["ntp"],
        content => template("ntp/ntp.conf")
    }
}
