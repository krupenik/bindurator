require 'spec_helper'
require 'bindurator/policy/exclude_by_country'

GeoIPCountryMock = Struct.new(:country_code2)
class GeoIPMock
  def country resource
    GeoIPCountryMock.new(
    case resource
    when /^1\./ then 'AU'
    when /^2\./ then 'FR'
    when /^3\./ then 'US'
    end
    )
  end
end

describe Bindurator::Policy::ExcludeByCountry do
  subject { described_class.new('au', GeoIPMock.new) }

  describe '#views' do
    it "extracts matching country into separate view" do
      expect(subject.views({
        'oceania' => [{'countries' => ['au', 'nz']}],
        'europe' => [{'countries' => ['at', 'de']}],
        'internal' => ['127.0.0.0/8'],
      })).to eq({
        'au' => [{'countries' => ['au']}],
        'oceania' => [{'countries' => ['nz']}],
        'europe' => [{'countries' => ['at', 'de']}],
        'internal' => ['127.0.0.0/8'],
      })
    end
  end

  describe '#zones' do
    it "filters zones matching country" do
      expect(subject.zones(['zone.au', 'zone.at', 'zone.ar'])).to match_array(['zone.at', 'zone.ar'])
    end
  end

  describe '#resources' do
    it "filters resources matching country" do
      expect(subject.resources(['1.0.0.1', '2.0.0.1', '3.0.0.1'])).to match_array(['2.0.0.1', '3.0.0.1'])
    end
  end
end
