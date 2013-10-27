module Bindurator
  class Zone
    TTL = 600

    def initialize config
      raise 'config should include data' unless
        config.is_a?(Hash) && config.has_key?(:data) && config[:data].is_a?(Hash)

      @config = config
      @data = @config[:data]

      raise 'data should include name and mail servers and at least one A record' unless
        [:ns, :mx, :a].all? { |k| @data.has_key?(k) && !@data[k].empty? }

      @config[:version] = @config[:version].to_i
      @config[:version] = Time.now.utc.strftime("%Y%m%d%H%M") if @config[:version] <= 0

      @config[:ttl] = @config[:ttl].to_i
      @config[:ttl] = TTL if @config[:ttl] <= 0
    end

    def generate
      [header, essentials, resources, nil].join("\n")
    end

    def version
      @config[:version]
    end

    def ttl
      @config[:ttl]
    end

    private

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
