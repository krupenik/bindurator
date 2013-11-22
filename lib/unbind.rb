require 'yaml'

require 'unbind/core_ext/hash/keys'
require 'unbind/core_ext/string/inflections'

require 'unbind/version'
require 'unbind/view'
require 'unbind/zone'

module Unbind
  Commands = %w(master slave zone).freeze

  @config = {}

  class << self
    attr_reader :config, :geoip

    def load_config config
      clear_config

      files = File.directory?(config) ? Dir["#{config}/**/*.conf"] : Dir[config]
      raise "No files could be found (search path: #{config})" if files.empty?
      files.each { |f| raise "File '#{f}' could not be loaded" unless load_file(f) }

      prepare_config

      true
    end

    def master(*)
      views.map { |v| v.master }.join("\n")
    end

    def slave(*)
      views.map { |v| v.slave }.join("\n")
    end

    def zone zone_names
      zone_names.map { |z| Unbind::Zone.new(z, @config[:zones][z]).generate }.join("\n")
    end

    # private

    def load_file f
      load_string(File.read(File.expand_path(f)))
    end

    def load_string s
      data = YAML.load(s)
      raise "config data should be a hash" unless data.is_a? Hash
      @config.merge!(data) and true
    end

    def clear_config
      @config = {}
    end

    def prepare_config
      symbolize_config
      init_geoip
    end

    def init_geoip
      if @config[:geoip_dat]
        begin
          require 'geoip'
          @geoip = GeoIP.new(@config[:geoip_dat])
        rescue LoadError
        end
      end
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

    def policies
      @policies ||= @config[:zones].reduce([]) { |a, (name, config)| a + (config[:policies] || []) }.map { |policy_name|
        Unbind::Policy.const_get(policy_name.camelize)
      }
    end

    def zones
      @zones ||= @config[:zones].map { |name, config| Unbind::Zone.new(name, config) }
    end

    def views
      @views ||= @config[:views].map { |name, clients| Unbind::View.new(name, {clients: clients, zones: zones}) }
    end
  end
end
