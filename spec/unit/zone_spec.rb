require 'unbind/zone'
require 'spec_helper'

describe Unbind::Zone do
  let(:valid_name) { 'a' }
  let(:valid_data) { {data: {ns: '.', mx: '.', a: {'' => ''}}} }

  describe '#new' do
    it 'requires a name' do
      expect { described_class.new() }.to raise_error
      expect { described_class.new(nil, valid_data) }.to raise_error
      expect { described_class.new('', valid_data) }.to raise_error
      expect { described_class.new(valid_name, valid_data) }.not_to raise_error
    end

    it 'requires essentials: ns, mx, a' do
      expect { described_class.new(valid_name) }.to raise_error
      expect { described_class.new(valid_name, nil) }.to raise_error
      expect { described_class.new(valid_name, {}) }.to raise_error
      expect { described_class.new(valid_name, valid_data) }.not_to raise_error
    end
  end

  context 'generators' do
    include_zone_definition

    describe '#header' do
      it 'generates zone header' do
        expect(zone.send :header).to match_array([
          "$TTL #{zone.ttl}",
          "@ SOA ns0 root (#{zone.version} 1d 10m 2w 10m)",
        ])
      end
    end

    describe '#essentials' do
      it 'generates zone essentials' do
        expect(zone.send :essentials).to match_array([
          '@ NS ns1',
          '@ NS ns2',
          '@ MX 1 mail',
        ])
      end
    end

    describe '#resources' do
      it 'generates zone resources' do
        expect(zone.send :resources).to match_array([
          '@ A 10.0.0.1',
          '@ A 10.0.0.2',
          '@ A 10.0.0.3',
          '* A 10.0.0.1',
          '* A 10.0.0.2',
          '* A 10.0.0.3',
          'mail A 10.0.0.1',
          'mail A 10.0.0.2',
          'ns1 A 10.0.0.1',
          'ns2 A 10.0.0.2',
          '@ TXT "txt data"',
          'imap CNAME mail',
          "_xmpp-client._tcp SRV 5222 0 5 ."
        ])
      end
    end
  end
end
