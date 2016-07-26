@environment = 'dev'
@role        = 'web'

@hosts = [
  {
    'host' => {
      'name' => 'web01',
      'host' => '192.168.0.1',
      'port' => 22
    },
  }
]

from_file("#{File.dirname(__FILE__)}/../../lib/run.rb")
run('ssh')
