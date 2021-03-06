define buildsystem::media_cfg($distro_name, $arch, $templatefile = 'buildsystem/media.cfg') {
    include buildsystem::var::repository
    include buildsystem::var::scheduler
    include buildsystem::repository
    
    file { "${buildsystem::var::repository::bootstrap_reporoot}/${distro_name}/${arch}/media/media_info/media.cfg":
        owner  => $buildsystem::var::scheduler::login,
        group  => $buildsystem::var::scheduler::login,
	content => template($templatefile),
    }
}
