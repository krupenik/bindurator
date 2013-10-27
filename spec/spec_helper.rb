def include_view_definition
  subject { Bindurator::View.new("test",
    clients: %w(country_US country_CA),
    masters: %w(10.0.0.1),
    slaves: %w(10.0.0.2 10.0.0.3),
    zones: %w(zone.us zone.ca))
  }
end

def include_zone_definition
  subject { Bindurator::Zone.new({
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
    }
  })}
end
