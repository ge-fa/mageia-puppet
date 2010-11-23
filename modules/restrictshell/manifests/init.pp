class restrictshell {
    class shell {
        file { '/usr/local/bin/sv_membersh.pl':
            ensure => present,
            owner => root,
            group => root,
            mode => 755,
            content => template("restrictshell/sv_membersh.pl"),
        }
    }

    class base {
        include shell
        $allow_svn = "0"
        $allow_git = "0"
        $allow_rsync = "0"
        $allow_pkgsubmit = "0"

        $ldap_pwfile = "/etc/ldap.secret"
        file { '/etc/membersh-conf.pl':
            ensure => present,
            owner => root,
            group => root,
            mode => 755,
            content => template("restrictshell/membersh-conf.pl"),
        }

        package { 'python-ldap':
            ensure => installed,
        }

        $pubkeys_directory = "/var/lib/pubkeys"
        file { $pubkeys_directory:
            ensure => directory,
            owner => root,
            group => root,
            mode => 755,
        }

        file { '/usr/local/bin/ldap-sshkey2file.py':
            ensure => present,
            owner => root,
            group => root,
            mode => 755,
            content => template("restrictshell/ldap-sshkey2file.py"),
            requires => Package['python-ldap']
        } 
    }

    class allow_svn_git_pkgsubmit inherits base {
        $allow_svn = "1"
        $allow_git = "1"
        $allow_pkgsubmit = "1"
    }
}
