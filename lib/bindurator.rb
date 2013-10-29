require 'active_support/core_ext/hash/keys'
require 'yaml'

require 'bindurator/policy/exclude_by_country'
require 'bindurator/version'
require 'bindurator/view'
require 'bindurator/zone'

module Bindurator
  Commands = %w(master slave).freeze

  class << self
    attr_reader :config

    def load_config config
      @config = {}

      files = File.directory?(config) ? Dir["#{config}/**/*.conf"] : Dir[config]
      raise "No files could be found (search path: #{config})" if files.empty?
      files.each { |f| raise "File '#{f}' could not be loaded" unless load_file(f) }

      @config.symbolize_keys!
      @config[:zones].each do |k, v|
        v.symbolize_keys!
        v[:data].symbolize_keys!
      end

      true
    end

    def master
    end

    def slave
      generate_keys
      generate_views :slave
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
  end
end
