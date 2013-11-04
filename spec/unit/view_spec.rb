require 'bindurator/view'
require 'spec_helper'

describe Bindurator::View do
  describe "#new" do
    let(:valid_data) { {clients: [], masters: [], slaves: [], zones: []} }

    it "requires both name and data" do
      expect { described_class.new() }.to raise_error
      expect { described_class.new(nil, nil) }.to raise_error
    end

    it "requires valid name" do
      expect { described_class.new(nil, valid_data) }.to raise_error
      expect { described_class.new("", valid_data) }.to raise_error
    end

    it "requires valid data" do
      expect { described_class.new("test", {clients: nil, masters: [], slaves: [], zones: []}) }.to raise_error
      expect { described_class.new("test", {clients: [], masters: nil, slaves: [], zones: []}) }.to raise_error
      expect { described_class.new("test", {clients: [], masters: [], slaves: nil, zones: []}) }.to raise_error
      expect { described_class.new("test", {clients: [], masters: [], slaves: [], zones: nil}) }.to raise_error
      expect { described_class.new("test", valid_data) }.not_to raise_error
    end
  end

  context "generators" do
    include_view_definition

    describe "#clients" do
      it "generates match-clients block" do
        expect(subject.send :clients).to eq("match-clients { key test; !tsig_keys; country_US; country_CA; };")
      end
    end

    describe "#file" do
      it "generates file block" do
        expect(subject.send :file, "zone.us").to eq("file \"pri/zone.us/test.zone\";")
      end
    end

    describe "#masters" do
      it "generates masters block" do
        expect(subject.send :masters).to eq("masters { 10.0.0.1 key test; };")
      end
    end

    describe "#servers" do
      it "generates servers list" do
        expect(subject.send :servers).to match_array([
          "server 10.0.0.2 { keys test; };",
          "server 10.0.0.3 { keys test; };",
        ])
      end
    end

    describe "#view_settings" do
      it "master should allow transfer with the key and notify" do
        expect(subject.send :view_settings, :master).to eq("allow-transfer { keys test; };\nnotify yes;")
      end
    end

    describe "#zones" do
      it "generates zones list for a slave" do
        expect(subject.send :zones, :slave).to match_array([
          "zone \"zone.us\" { type slave; masters { 10.0.0.1 key test; }; };",
          "zone \"zone.ca\" { type slave; masters { 10.0.0.1 key test; }; };",
        ])
      end

      it "generates zones list for the master" do
        expect(subject.send :zones, :master).to match_array([
          "zone \"zone.us\" { type master; file \"pri/zone.us/test.zone\"; };",
          "zone \"zone.ca\" { type master; file \"pri/zone.ca/test.zone\"; };",
        ])
      end
    end
  end
end
