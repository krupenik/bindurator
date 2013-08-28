require 'bindurator/view'
require 'spec_helper'

describe Bindurator::View do
  describe "#new" do
    it "should require both name and data" do
      expect { Bindurator::View.new() }.to raise_error
      expect { Bindurator::View.new(nil, nil) }.to raise_error
    end

    it "should require valid name" do
      expect { Bindurator::View.new(nil, {clients: [], masters: [], slaves: [], zones: []}) }.to raise_error
      expect { Bindurator::View.new("", {clients: [], masters: [], slaves: [], zones: []}) }.to raise_error
    end

    it "should require valid data hash" do
      expect { Bindurator::View.new("test", {clients: nil, masters: [], slaves: [], zones: []}) }.to raise_error
      expect { Bindurator::View.new("test", {clients: [], masters: nil, slaves: [], zones: []}) }.to raise_error
      expect { Bindurator::View.new("test", {clients: [], masters: [], slaves: nil, zones: []}) }.to raise_error
      expect { Bindurator::View.new("test", {clients: [], masters: [], slaves: [], zones: nil}) }.to raise_error
      expect { Bindurator::View.new("test", {clients: [], masters: [], slaves: [], zones: []}) }.not_to raise_error
    end
  end

  context "generators" do
    include_view_definition

    describe "#clients" do
      it "should generate match-clients block" do
        expect(subject.send :clients).to eq("match-clients { key test, !tsig_keys, country_US, country_CA };")
      end
    end

    describe "#file" do
      it "should generate file block" do
        expect(subject.send :file, "zone.us").to eq("file \"pri/zone.us/test.zone\";")
      end
    end

    describe "#masters" do
      it "should generate masters block" do
        expect(subject.send :masters).to eq("masters { 10.0.0.1 key test; };")
      end
    end

    describe "#servers" do
      it "should generate servers list" do
        expect(subject.send :servers).to eq([
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
      it "should generate zones list for a slave" do
        expect(subject.send :zones, :slave).to eq([
          "zone \"zone.us\" { type slave; masters { 10.0.0.1 key test; }; };",
          "zone \"zone.ca\" { type slave; masters { 10.0.0.1 key test; }; };",
        ])
      end

      it "should generate zones list for the master" do
        expect(subject.send :zones, :master).to eq([
          "zone \"zone.us\" { type master; file \"pri/zone.us/test.zone\"; };",
          "zone \"zone.ca\" { type master; file \"pri/zone.ca/test.zone\"; };",
        ])
      end
    end
  end
end
