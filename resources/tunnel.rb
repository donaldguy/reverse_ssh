property :name, String, name_property: true
property :host, String, default: lazy { node['reverse_ssh']['server_url'] }
property :port, [Fixnum, proc { |p| p == :from_search }], default: :from_search
property :local_port, Fixnum, default: 22

property :local_user, String, default: lazy { node['reverse_ssh']['local_user'] }
property :remote_user, String, default: lazy { node['reverse_ssh']['remote_user'] }
property :public_key_path, String, default: lazy { ::File.expand_path("~#{local_user}/.ssh/id_rsa.pub") }

property :install_autossh, [true, false], default: true
property :autossh_binary, String, default: '/usr/bin/autossh'
property :autossh_flags, String, default: lazy { "-M #{node['reverse_ssh']['autossh_monitoring_port']}" }
property :ssh_flags, String, default: "-t -t" #very force TTY allocation.

property :env_vars, Hash, default: lazy { {HOME: ::File.expand_path("~#{local_user}") } }
property :service_name, String, default: lazy { "rssh_#{name}" }
property :service_type, Symbol, default: :sysvinit

def _port
  if port.kind_of? Fixnum
    port
  elsif node['reverse_ssh']['port']
    node['reverse_ssh']['port']
  elsif port == :from_search
    max_port = node['reverse_ssh']['max_port']
    min_port = node['reverse_ssh']['min_port']


    ports_in_use = search(:node, 'reverse_ssh_port:*',
                    filter_result: { 'port' => ['reverse_ssh', 'port']}).map do |n|
                      n['port']
                    end
    ports_in_use.sort!

    min_port_in_use = ports_in_use.first || max_port+1

    if min_port_in_use-1 < min_port
      raise ArgumentError, "reverse_ssh: no more valid ports unused!"
    end

    min_port_in_use - 1
  else
    raise ArgumentError, "reverse_ssh: Port is somehow not right"
  end
end

 _service = lambda do |act|
  poise_service service_name do
    command "#{autossh_binary} #{autossh_flags} #{ssh_flags} -R #{_port}:localhost:#{local_port} #{remote_user}@#{host}"
    user local_user
    reload_signal 'USR1'

    environment env_vars

    provider service_type
    action act
  end
end

default_action :enable

action :enable do
  package 'autossh' if install_autossh

  instance_exec(:enable, &_service)

  if node['reverse_ssh']['publish_attributes']
    node.set['reverse_ssh']['port'] = _port
    node.set['reverse_ssh']['public_key'] = ::File.read(public_key_path)
  end
end

[:start, :stop, :restart, :reload].each do |act|
  action(act) do
    instance_exec(act, &_service)
  end
end

action :disable do
  instance_exec(:disable, &_service)

  node.rm('reverse_ssh', 'port')
  node.rm('reverse_ssh', 'public_key')
end
