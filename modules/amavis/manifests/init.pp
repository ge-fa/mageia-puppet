class amavis {
    package { "amavisd-new": }

    service { "amavisd":
        ensure => running,
        path => "/etc/init.d/amavisd",
        subscribe  => Package["amavisd-new"],
    }

    file { "/etc/amavisd/amavisd.conf":
        require => Package["amavisd-new"],
        content => template('amavis/amavisd.conf'),
        notify => Service['amavisd'],
    }
}
