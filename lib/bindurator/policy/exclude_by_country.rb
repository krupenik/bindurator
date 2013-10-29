require 'bindurator/policy/base'

module Bindurator
  module Policy
    class ExcludeByCountry < Base
      def initialize country, geoip
        @country = country.downcase
        @geoip = geoip
      end

      def views views_data
        extracted_views = {}

        views_data.each do |name, clients_list|
          clients_list.each do |clients|
            if (
              clients.is_a?(Hash) &&
              clients.has_key?("countries") &&
              clients["countries"].include?(@country) &&
              clients["countries"].length > 1
              )
              clients["countries"] -= [@country]
              extracted_views[@country] = [{"countries" => [@country]}]
            end
          end
        end

        views_data.merge(extracted_views)
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
