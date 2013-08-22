require 'bindurator/view'

describe Bindurator::View do
  describe "#new" do
    it "should require valid data hash" do
      expect { Bindurator::View.new(nil, nil) }.to raise_error
      expect { Bindurator::View.new("test", {clients: nil, masters: [], slaves: [], zones: []}) }.to raise_error
      expect { Bindurator::View.new("test", {clients: [], masters: nil, slaves: [], zones: []}) }.to raise_error
      expect { Bindurator::View.new("test", {clients: [], masters: [], slaves: nil, zones: []}) }.to raise_error
      expect { Bindurator::View.new("test", {clients: [], masters: [], slaves: [], zones: nil}) }.to raise_error
      expect { Bindurator::View.new("test", {clients: [], masters: [], slaves: [], zones: []}) }.not_to raise_error
    end
  end

  context "generators" do
    subject { Bindurator::View.new("test", clients: %w(country_US country_CA),
                                           masters: %w(10.0.0.1),
                                            slaves: %w(10.0.0.2 10.0.0.3),
                                             zones: %w(zone.us zone.ca)) }

    describe "#clients" do
      it "should generate match-clients block" do
        expect(subject.send :clients).to eq("match-clients { key test, !tsig_keys, country_US, country_CA };")
      end
    end

    describe "#file" do
      it "generates a file name for zone" do
        expect(subject.send :file, "zone.us").to eq("file \"pri/zone.us/test.zone\";")
      end
    end

    describe "#masters" do
      it "should generate masters block" do
        expect(subject.send :masters).to eq("masters { 10.0.0.1 key test; };")
      end
    end

    describe "#zones" do
      context "slave" do
        it "should generate slave zone definitions" do
          expect(subject.send :zones, :slave).to eq([
            "zone \"zone.us\" { type slave; masters { 10.0.0.1 key test; }; };",
            "zone \"zone.ca\" { type slave; masters { 10.0.0.1 key test; }; };"
            ])
        end
      end

      context "master" do
        it "should generate master zone definitions" do
          expect(subject.send :zones, :master).to eq([
            "zone \"zone.us\" { type master; file \"pri/zone.us/test.zone\"; };",
            "zone \"zone.ca\" { type master; file \"pri/zone.ca/test.zone\"; };"
            ])
        end
      end
    end

    describe "#slave" do
      it "should generate a view for slave" do
        expect(subject.slave).to eq(<<EOF
view "test" {
match-clients { key test, !tsig_keys, country_US, country_CA };
zone "zone.us" { type slave; masters { 10.0.0.1 key test; }; };
zone "zone.ca" { type slave; masters { 10.0.0.1 key test; }; };
};
EOF
        )
      end
    end
  end
end
