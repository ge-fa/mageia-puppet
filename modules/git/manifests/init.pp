class git {
    class common {
        package { 'git-core':
        }
    }

    class server inherits common {
        # http://www.kernel.org/pub/software/scm/git/docs/everyday.html#Repository%20Administration
        $git_base_path = '/git/'

        xinetd::service { "git":
            content => template('git/xinetd')
        }

        file { "$git_base_path":
            ensure => directory
        }
        
        file { "/usr/local/bin/create_git_repo.sh":
             ensure => present,
             owner => root,
             group => root,
             mode => 755,
             content => template('git/create_git_repo.sh')
        }


        # TODO
        # define common syntax check, see svn 
        #          http://stackoverflow.com/questions/3719883/git-hook-syntax-check
        #        proper policy : fast-forward-only 
        #              ( http://progit.org/book/ch7-4.html ) 
        #            no branch ?
        #            no binary
        #            no big file
        #            no empty commit message
        #            no commit from root
        #        see http://www.itk.org/Wiki/Git/Hooks 
        #        automated push to another git repo ( see http://noone.org/blog/English/Computer/VCS/Thoughts%20on%20Gitorious%20and%20GitHub%20plus%20a%20useful%20git%20hook.futile
        # 
        # how do we handle commit permission ?
        #   mail sending
        # 
    }

    define repository($description = '',
                      $group ) {

        include git::server
        # http://eagleas.livejournal.com/18907.html
        # TODO group permission should be handled here too
        exec { "/usr/local/bin/create_git_repo.sh $name":
            user => root,
            group => $group,
            creates => $name,
        }

        file { "$name/git-daemon-export-ok":
            ensure => present,
            require => Exec["/usr/local/bin/create_git_repo.sh $name"]
        }
        
        file { "$name/description":
            ensure => present,
            content => $description,
            require => File["$name/git-daemon-export-ok"]
        }
    }

    define svn_repository($source,
                          $std_layout = true,
                          $refresh = '*/5') {
        include git::svn
        include git::server
        # a cron job
        # a exec
        if $std_layout {
            $options = "-s"
        } else {
            $options = " "
        }

        exec { "/usr/bin/git svn init $options $source $name":
            alias => "git svn $name",
            creates => $name,
        }

        cron { "update $name":
            # done in 2 times, so fetch can fill the repo after init
            command => "cd $name && /usr/bin/git svn fetch && /usr/bin/git svn rebase" ,
            minute => $refresh
        }
        # TODO find a way to prevent commit
        file { "$name/.git/hooks/pre-receive":
            ensure => present,
            owner => root,
            group => root,
            mode => 755,
            content => "#!/bin/bash\nfalse",
            require => Exec["git svn $name"]
        }
    }

    class client inherits common {


    }

    class svn inherits client {
        package { "git-svn":
            ensure => installed
        }
    }

    define snapshot($source, $refresh ='*/5', $user = 'root') {
        include git::client
        #TODO
        # should handle branch -> clone -n + branch + checkout 
        # create a script 
        # Idealy, should be handled by vcsrepo https://github.com/bruce/puppet-vcsrepo   
        # once it is merged in puppet 
        exec { "/usr/bin/git clone $source $name":
            creates => $name,
            user => $user
        }
        
        cron { "update $name":
            # FIXME no -q ?
            command => "cd $name && /usr/bin/git pull",
            user => $user,
            minute => $refresh
        }
    }
}



