define sympa::list( $subject,
                    $profile = false,
                    $language = 'en',
                    $topics = false,
                    $reply_to = false,
                    $sender_email = false,
                    $sender_ldap_group = false,
                    $subscriber_ldap_group = false,
                    $public_archive = true,
                    $subscription_open = false) {

    include sympa::variable
    $ldap_password = extlookup(i'sympa_ldap','x')
    $custom_subject = $name

    $xml_file = "/etc/sympa/lists_xml/$name.xml"

    if $sender_email {
        $sender_email_file = regsubst($sender_email,'\@','-at-')
    } else {
        $sender_email_file = ''
    }

    file { $xml_file:
        content => template('sympa/list.xml'),
        require => Package[sympa],
    }

    exec { "sympa.pl --create_list --robot=$sympa::variable::vhost --input_file=$xml_file":
        require => File[$xml_file],
        creates => "/var/lib/sympa/expl/$name",
        before  => File["/var/lib/sympa/expl/$name/config"],
    }

    file { "/var/lib/sympa/expl/$name/config":
        owner   => 'sympa',
        group   => 'sympa',
        mode    => '0750',
        content => template('sympa/config'),
        notify  => Service['sympa'],
    }

    if $sender_ldap_group {
        if ! defined(Sympa::Scenario::Sender_ldap_group[$sender_ldap_group]) {
            sympa::scenario::sender_ldap_group { $sender_ldap_group: }
        }
    }

    if $sender_email {
        if ! defined(Sympa::Scenario::Sender_email[$sender_email]) {
            sympa::scenario::sender_email { $sender_email: }
        }
    }

    if $subscriber_ldap_group {
        if ! defined(Sympa::Search_filter::Ldap[$subscriber_ldap_group]) {
            sympa::search_filter::ldap { $subscriber_ldap_group: }
        }
    }
}

