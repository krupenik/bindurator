module Bindurator
  class View
    def self.expand_countries clients
      clients.flat_map { |i|
        if i.is_a?(Hash) && i.has_key?("countries")
          i["countries"].map { |c| "country_#{c.upcase}" }
        else
          i
        end
      }
    end

    def initialize name, config
      raise "view must have a name" unless name.is_a?(String) && 0 < name.length
      raise "config should include clients and zones lists" unless
        config.is_a?(Hash) && [:clients, :zones].all? { |k| config.has_key?(k) && config[k].is_a?(Array) }

      @name = name
      @clients = config[:clients]
      @zones = config[:zones]
    end

    def slave
      ["view \"#{@name}\" {", match_clients, zones(:slave), "};\n"].join("\n")
    end

    def master
      ["view \"#{@name}\" {", match_clients, servers, view_settings(:master), zones(:master), "};\n"].join("\n")
    end

    def clients
      self.class.expand_countries(@clients)
    end

    private

    def slaves
      @zones.reduce([]) { |a, e| a + e.slaves }
    end

    def match_clients
      "match-clients { key #{@name}; !tsig_keys; #{clients.join("; ")}; };"
    end

    def file zone
      "file \"pri/#{zone.name}/#{@name}.zone\";"
    end

    def masters zone
      "masters { %s key %s; };" % [zone.master, @name]
    end

    def servers
      slaves.map { |slave|
        "server #{slave} { keys #{@name}; };"
      }
    end

    def view_settings role
      case role
      when :master
        "allow-transfer { keys #{@name}; };\nnotify yes;"
      end
    end

    def zones role
      @zones.flat_map { |zone|
        ([zone.name] + zone.aliases).flat_map { |zone_name|
          "zone \"#{zone_name}\" { type #{role}; #{:master == role ? file(zone) : masters(zone) } };"
        }
      }
    end
  end
end
