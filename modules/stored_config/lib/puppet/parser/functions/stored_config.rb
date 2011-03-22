require 'puppet/rails'

# function :
#  list_exported_ressources($resource)
#    -> renvoie un array de title
#  get_fact($node,$fact)
#    -> renvoie le fact

module Puppet::Parser::Functions
    newfunction(:list_exported_ressources, :type => :rvalue) do |args|
        exported_type = args[0]
        #TODO manage tags
        Puppet::Rails.connect()
        # TODO use find_each
        return Puppet::Rails::Resource.find(:all, 
                                            :conditions => { :exported => true, 
                                                             :restype => exported_type }).map { |r| r.title }
    end
end
