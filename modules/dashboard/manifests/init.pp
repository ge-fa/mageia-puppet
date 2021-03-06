class dashboard {
    $dashboard_login = 'dashboard'
    $dashboard_home_dir = "/var/lib/$dashboard_login"
    $dashboard_dir = "$dashboard_home_dir/dashboard"
    $dashboard_bindir = "$dashboard_home_dir/bin"
    $dashboard_wwwdir = "/var/www/vhosts/dashboard.$::domain"

    user { $dashboard_login:
        comment => 'dashboard system user',
        home    => $dashboard_home_dir,
    }

    subversion::snapshot { $dashboard_dir:
        source => "svn://svn.$::domain/soft/dashboard/",
    }

    package { 'php-cli': }

    file { $dashboard_wwwdir:
        ensure => directory,
        owner  => $dashboard_login,
        group  => $dashboard_login,
    }

    file { $dashboard_bindir:
        ensure => directory,
    }

    file { "$dashboard_bindir/make_report":
        mode    => '0755',
        content => template('dashboard/make_report'),
    }

    apache::vhost::base { "dashboard.$::domain":
        location => $dashboard_wwwdir,
    }

    cron { 'update dashboard':
        command => "$dashboard_bindir/make_report",
        user    => $dashboard_login,
        hour    => '*/2',
        minute  => '15',
    }
}
