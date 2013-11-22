def include_zone_definition
  require 'unbind/zone'

  zone = Unbind::Zone.new("zone.ua", {
    master: '10.0.0.1',
    slaves: %w(10.0.0.2 10.0.0.3),
    aliases: %w(zone.uk zone.us),
    data: {
      ns: %w(ns1 ns2),
      mx: 'mail',
      a: {
        '@, *' => %w(10.0.0.1 10.0.0.2 10.0.0.3),
        'mail' => %w(10.0.0.1 10.0.0.2),
        'ns1' => '10.0.0.1',
        'ns2' => '10.0.0.2',
      },
      txt: {
        '@' => '"txt data"',
      },
      cname: {
        'imap' => 'mail',
      },
      srv: {
        '_xmpp-client._tcp' => '5222 0 5 .'
      },
    },
  })

  @zone = zone

  subject(:zone) { zone }
end

def include_view_definition
  include_zone_definition

  require 'unbind/view'

  view = Unbind::View.new("test", {
    clients: [{"countries" => %w(ua uk us)}],
    zones: [@zone],
  })

  subject(:view) { view }
end

def include_full_config
  Unbind.instance_variable_set(:@config, {
    views: {
      'internal' => ['127.0.0.0/8', '10.0.0.0/24'],
      'external' => [{
        'countries' => ['ua', 'uk', 'us', 'tt'],
      }],
    },
    zones: {
      'zone.ua' => {
        master: '10.0.0.1',
        slaves: ['192.168.0.2', '192.168.0.3'],
        aliases: ['zone.uk', 'zone.us'],
        data: {
          ns: ['ns1', 'ns2'],
          mx: ['mx1'],
          a: {
            'ns1' => '192.168.0.2',
            'ns2' => '192.168.0.3',
            'mx1' => '192.168.0.2',
            '@, *' => ['192.168.0.2', '192.168.0.3'],
          },
        },
      },
    },
  })

  Unbind.send :prepare_config

  subject { Unbind }
end
