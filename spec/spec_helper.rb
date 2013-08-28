def include_view_definition
  subject { Bindurator::View.new("test",
    clients: %w(country_US country_CA),
    masters: %w(10.0.0.1),
    slaves: %w(10.0.0.2 10.0.0.3),
    zones: %w(zone.us zone.ca))
  }
end
