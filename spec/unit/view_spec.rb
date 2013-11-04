require 'bindurator/view'
require 'spec_helper'

describe Bindurator::View do
  describe ".expand_countries" do
    it "expands countries list" do
      expect(described_class.expand_countries([{"countries" => %w(ua uk us)}])).to match_array([
        'country_UA', 'country_UK', 'country_US'
      ])
    end
  end

  describe "#new" do
    let(:valid_name) { 'a' }
    let(:valid_data) { {clients: [], zones: []} }

    it "requires valid name" do
      expect { described_class.new(nil, valid_data) }.to raise_error
      expect { described_class.new('', valid_data) }.to raise_error
    end

    it "requires valid data" do
      expect { described_class.new(valid_name, {clients: nil, zones: []}) }.to raise_error
      expect { described_class.new(valid_name, {clients: [], zones: nil}) }.to raise_error
    end

    it "requires both valid name and valid data" do
      expect { described_class.new() }.to raise_error
      expect { described_class.new(nil, nil) }.to raise_error
      expect { described_class.new(valid_name, valid_data) }.not_to raise_error
    end
  end

  context "generators" do
    include_view_definition

    describe "#match_clients" do
      it "generates match-clients block" do
        expect(view.send :match_clients).to eq("match-clients { key test; !tsig_keys; country_UA; country_UK; country_US; };")
      end
    end

    describe "#servers" do
      it "generates servers list" do
        expect(view.send :servers).to match_array([
          "server 10.0.0.2 { keys test; };",
          "server 10.0.0.3 { keys test; };",
        ])
      end
    end

    describe "#view_settings" do
      it "master should allow transfer with the key and notify" do
        expect(view.send :view_settings, :master).to eq("allow-transfer { keys test; };\nnotify yes;")
      end
    end

    describe "#zones" do
      it "generates zones list for a slave" do
        expect(view.send :zones, :slave).to match_array([
          "zone \"zone.ua\" { type slave; masters { 10.0.0.1 key test; }; };",
          "zone \"zone.uk\" { type slave; masters { 10.0.0.1 key test; }; };",
          "zone \"zone.us\" { type slave; masters { 10.0.0.1 key test; }; };",
        ])
      end

      it "generates zones list for the master" do
        expect(view.send :zones, :master).to match_array([
          "zone \"zone.ua\" { type master; file \"pri/zone.ua/test.zone\"; };",
          "zone \"zone.uk\" { type master; file \"pri/zone.ua/test.zone\"; };",
          "zone \"zone.us\" { type master; file \"pri/zone.ua/test.zone\"; };",
        ])
      end
    end
  end
end
