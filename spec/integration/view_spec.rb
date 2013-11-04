require 'bindurator/view'
require 'spec_helper'

describe Bindurator::View do
  include_view_definition

  describe "#slave" do
    it "generates the view for a slave" do
      expect(subject.slave).to eq(<<EOF
view "test" {
match-clients { key test; !tsig_keys; country_US; country_CA; };
zone "zone.us" { type slave; masters { 10.0.0.1 key test; }; };
zone "zone.ca" { type slave; masters { 10.0.0.1 key test; }; };
};
EOF
      )
    end
  end

  describe "#master" do
    it "generates the view for the master" do
      expect(subject.master).to eq(<<EOF
view "test" {
match-clients { key test; !tsig_keys; country_US; country_CA; };
server 10.0.0.2 { keys test; };
server 10.0.0.3 { keys test; };
allow-transfer { keys test; };
notify yes;
zone "zone.us" { type master; file "pri/zone.us/test.zone"; };
zone "zone.ca" { type master; file "pri/zone.ca/test.zone"; };
};
EOF
      )
    end
  end
end
