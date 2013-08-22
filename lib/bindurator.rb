require 'yaml'
require "bindurator/version"

module Bindurator
  Commands = %w(master slave).freeze

  @config = {}

  class << self
    def load_config config
      files = File.directory?(config) ? Dir["#{config}/**/*.conf"] : Dir[config]
      raise "No files could be found (search path: #{config})" if files.empty?
      files.each { |f| raise "File '#{f}' could not be loaded" unless load_file(f) }
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

    def generate_views role=:slave

    end

    def generate_view role, data={}
      View.new(data).send role
    end
  end
end
