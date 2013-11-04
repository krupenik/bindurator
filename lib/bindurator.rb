require 'yaml'

require 'bindurator/core_ext/hash/keys'

require 'bindurator/version'
require 'bindurator/view'
require 'bindurator/zone'

module Bindurator
  Commands = %w(master slave zone).freeze

  @config = {}
  @policies = []
  @views = []
  @zones = []

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

    def collect_zones
      @zones = @config[:zones].map { |name, config| Bindurator::Zone.new(name, config) }
    end

    def collect_views
      collect_zones

      @views = @config[:views].map { |name, clients| Bindurator::View.new(name, {clients: clients, zones: @zones}) }
    end

    def generate_views role
      collect_views

      @views.map { |v| v.send(role) }.join("\n")
    end
  end
end
