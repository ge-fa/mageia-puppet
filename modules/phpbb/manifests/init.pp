class phpbb {
    class base {
        $db = "phpbb"
        $user = "phpbb"

        include apache::mod_php
        include mysql

        package { ["php-gd","php-xml","php-zlib","php-ftp","php-magickwand","php-pgsql" ] :
            ensure => installed
        }

        package { "perl-DBD-Pg":
            ensure => installed
        }

        file { "/usr/local/bin/phpbb_apply_config.pl":
             ensure => present,
             owner => root,
             group => root,
             mode => 755,
             source => 'puppet:///modules/phpbb/phpbb_apply_config.pl',
        }

        # TODO phpbb config
        # cookie_domain 
        # board_contact
        # 
        define phpbb_config($value) {
            exec { "/usr/local/bin/phpbb_apply_config.pl $name":
                user => root,
                environment => ["PGDATABASE=$database", "PGUSER=$user", "PGPASSWORD=$pgsql_password", "PGHOST=pgsql.$domain", "VALUE=$value"],
                require => File["/usr/local/bin/phpbb_apply_config.pl"],
            }
        }

        $pgsql_password = extlookup("phpbb_pgsql",'x')
        @@postgresql::user { $user:
            password => $pgsql_password,
        }

        $forums_dir = "/var/www/forums/"
        file { "$forums_dir":
            ensure => directory,
            owner => root,
            group => root,
        }
    }

    define php_instance() {
        $lang = $name
        $database = "${db}_$lang"

        include git::client

        exec { "git clone git://git.$domain/forum/ $lang":
            cwd => $forums_dir,
            creates => "$forums_dir/$lang",   
        }

        file { "$forums_dir/$lang/phpBB/config.php":
            ensure => present,
            owner => root,
            group => root,
            mode => 644,
            content => template("phpbb/config.php"),
        }

        include php::base

        @@postgresql::database { $database:
            description => "Phpbb database",
            user => $user,
            require => Postgresql::User[$user]
        }


        phpbb_config { "ldap_user":
            value => "cn=phpbb-friteuse,ou=System Accounts,$dc_suffix",
        }

        phpbb_config { "ldap_server":
            value => "ldap.$domain",
        }

        $ldap_password = extlookup("phpbb_ldap",'x')
        phpbb_config { "ldap_password":
            value => $ldap_password,
        }

        phpbb_config { "ldap_base_dn":
            value => "ou=People,$dc_suffix",
        }
    }
}
