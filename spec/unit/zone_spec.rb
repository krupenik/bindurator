require 'bindurator/zone'
require 'spec_helper'

describe Bindurator::Zone do
  let(:valid_data) { {ns: 'ns1', mx: 'mail', a: ['ns1' => '10.0.0.1']}}

  describe '#new' do
    it 'requires version and data' do
      expect { described_class.new() }.to raise_error
      expect { described_class.new(nil, nil) }.to raise_error
    end

    it 'requires valid version' do
      expect { described_class.new(nil, valid_data) }.to raise_error
      expect { described_class.new(0, valid_data) }.to raise_error
    end

    it 'requires essentials: ns, mx, a' do
      expect { described_class.new(1) }.to raise_error
      expect { described_class.new(1, {}) }.to raise_error
      expect { described_class.new(1, valid_data) }.not_to raise_error
    end
  end

  context 'generators' do
    include_zone_definition

    describe '#header' do
      it 'generates zone header' do
        expect(subject.send :header).to match_array([
          "$TTL #{described_class::TTL}",
          "@ SOA ns0 root (#{subject.version} 1d 10m 2w 10m)",
        ])
      end
    end

    describe '#essentials' do
      it 'generates zone essentials' do
        expect(subject.send :essentials).to match_array([
          '@ NS ns1',
          '@ NS ns2',
          '@ MX 1 mail',
        ])
      end
    end

    describe '#resources' do
      it 'generates zone resources' do
        expect(subject.send :resources).to match_array([
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
