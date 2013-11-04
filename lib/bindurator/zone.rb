module Bindurator
  class Zone
    TTL = 600

    attr_reader :aliases, :master, :name, :slaves, :ttl, :version

    def initialize name, config
      raise 'zone should have a valid name' unless name =~ /\A[\w\-\.]+\z/

      @name = name

      raise 'zone config should include data' unless
        config.is_a?(Hash) && config.has_key?(:data) && config[:data].is_a?(Hash)

      @config = config
      @data = @config[:data]

      # raise 'zone data should include name and mail servers and at least one A record' unless
      #   [:ns, :mx, :a].all? { |k| @data.has_key?(k) && !@data[k].empty? }

      sanitize_ttl
      sanitize_version
      assign_optional_data
    end

    def generate
      [header, essentials, resources, nil].join("\n")
    end

    private

    def assign_optional_data
      [:aliases, :master, :slaves].each do |i|
        instance_variable_set(:"@#{i}", @config[i] || [])
      end
    end

    def sanitize_ttl
      @ttl = @config[:ttl].to_i
      @ttl = TTL if @ttl <= 0
    end

    def sanitize_version
      @version = @config[:version].to_i
      @version = Time.now.utc.strftime("%Y%m%d%H%M") if @version <= 0
    end

    def header
      [
        "$TTL #{ttl}",
        "@ SOA ns0 root (#{version} 1d 10m 2w 10m)",
      ]
    end

    def essentials
      Array(@data[:ns]).map { |name| "@ NS #{name}" } +
      Array(@data[:mx]).map.with_index { |name, prio| "@ MX #{prio+1} #{name}" }
    end

    def resources
      (@data.keys - [:ns, :mx]).reduce([]) { |a, type|
        a + @data[type].reduce([]) { |a, (names, addresses)|
          a + names.split(/\s*,\s*/).reduce([]) { |a, name|
            a + Array(addresses).reduce([]) { |a, address|
              a + ["#{name} #{type.upcase} #{address}"]
            }
          }
        }
      }
    end
  end
end
