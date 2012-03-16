class buildsystem::scheduler {
        # until ulri is splitted from main iurt rpm
        include ssh::auth
        include buildsystem::iurt::packages
        include buildsystem::iurt::upload
        include buildsystem::scheduler::var

        $login = $buildsystem::scheduler::var::login
        $homedir = $buildsystem::scheduler::var::homedir        

        buildsystem::sshuser { $login:
            homedir => $homedir,
            comment => 'System user used to schedule builds',
        }
}
