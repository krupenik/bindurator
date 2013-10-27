require 'bindurator/policy/base'

module Bindurator
  module Policy
    class ExcludeByCountry < Base
      def initialize country, geoip
        @country = country.downcase
        @geoip = geoip
      end

      def views
        # TODO: add view separation by match-clients
      end

      def zones zone_names
        zone_names.reject { |i| i.downcase.end_with?(@country) }
      end

      def resources resources
        resources.reject { |i| @geoip.country(i).country_code2.downcase == @country }
      end
    end
  end
end
