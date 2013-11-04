require 'bindurator'
require 'spec_helper'

describe Bindurator do
  include_full_config

  describe '.slave' do
    it "generates config for slaves" do
      expect(subject.slave).to eq(<<EOF
view "internal" {
match-clients { key internal; !tsig_keys; 127.0.0.0/8; 10.0.0.0/24; };
zone "zone.ua" { type slave; masters { 10.0.0.1 key internal; }; };
zone "zone.uk" { type slave; masters { 10.0.0.1 key internal; }; };
zone "zone.us" { type slave; masters { 10.0.0.1 key internal; }; };
};

view "external" {
match-clients { key external; !tsig_keys; country_UA; country_UK; country_US; country_TT; };
zone "zone.ua" { type slave; masters { 10.0.0.1 key external; }; };
zone "zone.uk" { type slave; masters { 10.0.0.1 key external; }; };
zone "zone.us" { type slave; masters { 10.0.0.1 key external; }; };
};
EOF
      )
    end
  end

  describe '.master' do
    it "generates config for the master" do
      expect(subject.master).to eq(<<EOF
view "internal" {
match-clients { key internal; !tsig_keys; 127.0.0.0/8; 10.0.0.0/24; };
server 192.168.0.2 { keys internal; };
server 192.168.0.3 { keys internal; };
allow-transfer { keys internal; };
notify yes;
zone "zone.ua" { type master; file "pri/zone.ua/internal.zone"; };
zone "zone.uk" { type master; file "pri/zone.ua/internal.zone"; };
zone "zone.us" { type master; file "pri/zone.ua/internal.zone"; };
};

view "external" {
match-clients { key external; !tsig_keys; country_UA; country_UK; country_US; country_TT; };
server 192.168.0.2 { keys external; };
server 192.168.0.3 { keys external; };
allow-transfer { keys external; };
notify yes;
zone "zone.ua" { type master; file "pri/zone.ua/external.zone"; };
zone "zone.uk" { type master; file "pri/zone.ua/external.zone"; };
zone "zone.us" { type master; file "pri/zone.ua/external.zone"; };
};
EOF
      )
    end
  end
end
