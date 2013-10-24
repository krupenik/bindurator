module Bindurator
  class Zone
    TTL = 600

    attr_accessor :version

    def initialize version, data
      raise 'zone should have a version' unless version.is_a?(Numeric) && version > 0
      raise 'data should include name and mail servers and at least one A record' unless
      data.is_a?(Hash) && [:ns, :mx, :a].all? { |k| data.has_key?(k) && !data[k].empty? }

      @version = version
      @data = data
    end

    def generate
      [header, essentials, resources, nil].join("\n")
    end

    private

    def header
      [
        "$TTL #{TTL}",
        "@ SOA ns0 root (#{@version} 1d 10m 2w 10m)",
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
