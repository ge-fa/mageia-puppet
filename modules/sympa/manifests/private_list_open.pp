# list with private archive, restricted to member of $ldap_group
# everybody can post
# used for contact alias
define sympa::private_list_open($subject,
                                $subscriber_ldap_group,
                                $language = 'en',
                                $topics = false) {
    list { $name:
        subject               => $subject,
        profile               => '',
        language              => $language,
        topics                => $topics,
        subscriber_ldap_group => $subscriber_ldap_group,
        public_archive        => false,
    }
}


