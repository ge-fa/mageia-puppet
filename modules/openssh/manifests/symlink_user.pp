define openssh::symlink_user() {
    include openssh::pubkeys_directory
    $pubkeys_directory = $openssh::pubkeys_directory::pubkeys_directory
    file { "$pubkeys_directory/$name":
        ensure => directory,
        owner  => $name,
        group  => $name,
        mode   => '0700',
    }

    file { "$pubkeys_directory/$name/authorized_keys":
        # FIXME : fragile approximation for $HOME
        ensure => link,
        target => "/home/$name/.ssh/authorized_keys",
        mode   => '0700',
    }
}

