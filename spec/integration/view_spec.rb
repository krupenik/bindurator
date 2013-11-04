require 'bindurator/view'
require 'spec_helper'

describe Bindurator::View do
  include_view_definition

  describe "#slave" do
    it "generates the view for a slave" do
      expect(subject.slave).to eq(<<EOF
view "test" {
match-clients { key test; !tsig_keys; country_UA; country_UK; country_US; };
zone "zone.ua" { type slave; masters { 10.0.0.1 key test; }; };
zone "zone.uk" { type slave; masters { 10.0.0.1 key test; }; };
zone "zone.us" { type slave; masters { 10.0.0.1 key test; }; };
};
EOF
      )
    end
  end

  describe "#master" do
    it "generates the view for the master" do
      expect(subject.master).to eq(<<EOF
view "test" {
match-clients { key test; !tsig_keys; country_UA; country_UK; country_US; };
server 10.0.0.2 { keys test; };
server 10.0.0.3 { keys test; };
allow-transfer { keys test; };
notify yes;
zone "zone.ua" { type master; file "pri/zone.ua/test.zone"; };
zone "zone.uk" { type master; file "pri/zone.ua/test.zone"; };
zone "zone.us" { type master; file "pri/zone.ua/test.zone"; };
};
EOF
      )
    end
  end
end
