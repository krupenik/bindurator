require 'bindurator/zone'
require 'spec_helper'

describe Bindurator::Zone do
  include_zone_definition

  describe "#generate" do
    it "generates zone file content" do
      expect(subject.generate).to eq(<<EOF
$TTL #{subject.ttl}
@ SOA ns0 root (#{subject.version} 1d 10m 2w 10m)
@ NS ns1
@ NS ns2
@ MX 1 mail
@ A 10.0.0.1
@ A 10.0.0.2
@ A 10.0.0.3
* A 10.0.0.1
* A 10.0.0.2
* A 10.0.0.3
mail A 10.0.0.1
mail A 10.0.0.2
ns1 A 10.0.0.1
ns2 A 10.0.0.2
@ TXT "txt data"
imap CNAME mail
_xmpp-client._tcp SRV 5222 0 5 .
EOF
      )
    end
  end
end
