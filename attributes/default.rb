default['reverse_ssh']['target_name'] = 'default'
default['reverse_ssh']['server_url'] = nil
default['reverse_ssh']['target_port'] = :from_search

default['reverse_ssh']['local_user'] = 'ubuntu'
default['reverse_ssh']['remote_user'] = 'rssh'

default['reverse_ssh']['publish_attributes'] = true
default['reverse_ssh']['max_port'] = 19999
default['reverse_ssh']['min_port'] = 1025

default['reverse_ssh']['autossh_monitoring_port'] = 20000
