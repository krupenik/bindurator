require 'active_support/core_ext/hash/keys'
require 'active_support/inflector'
require 'yaml'

require 'bindurator/core_ext/hash/keys'

require 'bindurator/version'
require 'bindurator/view'
require 'bindurator/zone'

module Bindurator
  Commands = %w(master slave zone).freeze

  @config = {}
  @policies = []

  class << self
    attr_reader :config, :geoip

    def load_config config
      files = File.directory?(config) ? Dir["#{config}/**/*.conf"] : Dir[config]
      raise "No files could be found (search path: #{config})" if files.empty?
      files.each { |f| raise "File '#{f}' could not be loaded" unless load_file(f) }

      prepare_config

      true
    end

    def master(*)
      generate_views :master
    end

    def slave(*)
      generate_views :slave
    end

    def zone zone_name
      Bindurator::Zone.new(@config[:zones][zone_name[0]]).generate
    end

    private

    def load_file f
      load_string(File.read(File.expand_path(f)))
    end

    def load_string s
      data = YAML.load(s)
      raise "config data should be a hash" unless data.is_a? Hash
      @config.merge!(data) and true
    end

    def prepare_config
      symbolize_config
      collect_policies
      init_geoip
    end

    def init_geoip
      @geoip = GeoIP.new(@config[:geoip_dat]) if @config[:geoip_dat] && defined?(GeoIP)
    end

    def symbolize_config
      @config.symbolize_keys!

      @config[:views] ||= {}
      @config[:zones] ||= {}

      @config[:zones].each do |k, v|
        v.symbolize_keys!
        v[:data].symbolize_keys!
      end
    end

    def collect_policies
      @policies = @config[:zones].reduce([]) { |a, (name, data)|
        (a + (data[:policies] || []))
      }.uniq.map { |policy_name|
        "Bindurator::Policy::#{policy_name.classify}".constantize rescue nil
      }.compact
    end

    def generate_views role
      @config[:views].map { |name, clients|
        data = {
          clients: expand_countries(clients),
          zones: @config[:zones].reduce([]) { |a, (name, data)| a + [name] + (data[:aliases] || []) }.uniq,
          masters: @config[:zones].reduce([]) { |a, (name, data)| a + (data[:masters] || []) }.uniq,
          slaves: @config[:zones].reduce([]) { |a, (name, data)| a + (data[:slaves] || []) }.uniq,
        }

        Bindurator::View.new(name, data).send(role)
      }.join("\n")
    end

    def expand_countries clients
      clients.map { |i|
        if i.is_a?(Hash) && i.has_key?("countries")
          i["countries"].map { |c| "country_#{c.upcase}" }
        else
          i
        end
      }
    end
  end
end
