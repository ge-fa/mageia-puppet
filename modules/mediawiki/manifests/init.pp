class mediawiki {
    class base {

        $root = "/srv/wiki/"

        include apache::mod_php

        package { "mediawiki-minimal":
            ensure => installed,
        }

        file { $root:
            ensure => directory,
        }
       
        $user = "mediawiki"
 
        $pgsql_password = extlookup("mediawiki_pgsql",'x')
        @@postgresql::user { $user:
            password => $pgsql_password,
        }

        # TODO create the ldap user   
        $ldap_password = extlookup('mediawiki_ldap','x')

        # TODO write the web configuration
        apache::vhost_base { "wiki.$domain":
            location => $root,
            content => template("mediawiki/wiki_vhost.conf"),
        }

        apache::vhost_base { "ssl_wiki.$domain":
            location => $root,
            use_ssl => true,
            vhost => "wiki.$domain",
            content => template("mediawiki/wiki_vhost.conf"),
        }



        # add index.php
    }        

    # do wiki basic installation

    define instance($title) {

        include mediawiki::base

        $path = $name
        $lang = $name
        $wiki_root = "$mediawiki::base::root/$path"
        $db_name = "mediawiki_$name"
        $db_user = "$mediawiki::base::user"
        $db_password = "$mediawiki::base::pgsql_password"
        $secret_key = extlookup("mediawiki_secretkey",'x')

        file { "$wiki_root":
            ensure => directory 
        }

        exec { "wikicreate $name":
            command => "mediawiki-create $wiki_root",
            cwd => "$mediawiki::base::root",
            require => [File["$wiki_root"],Package['mediawiki-minimal']],
            creates => "$wiki_root/index.php",
        }

        postgresql::database { "$db_name":
            user => $db_user,
        }

        file { "$wiki_root/LocalSettings.php":
            ensure => present,
            content => template("mediawiki/LocalSettings.php")
        }
    }
}