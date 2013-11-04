module Bindurator
  class View
    def initialize name, data
      raise "view must have a name" unless name.is_a?(String) && 0 < name.length
      raise "data should include clients, masters, slaves and zones lists" unless
        data.is_a?(Hash) && [:clients, :masters, :slaves, :zones].all? { |k| data.has_key?(k) && data[k].is_a?(Array) }

      @name = name
      @clients = data[:clients]
      @masters = data[:masters]
      @slaves = data[:slaves]
      @zones = data[:zones]
    end

    def slave
      ["view \"#{@name}\" {", clients, zones(:slave), "};\n"].join("\n")
    end

    def master
      ["view \"#{@name}\" {", clients, servers, view_settings(:master), zones(:master), "};\n"].join("\n")
    end

    private

    def clients
      "match-clients { key #{@name}; !tsig_keys; #{@clients.join("; ")}; };"
    end

    def file zone
      "file \"pri/#{zone}/#{@name}.zone\";"
    end

    def masters
      ["masters {", @masters.reduce("") { |a, e| "%s key %s;" % [e, @name]}, "};"].join(" ")
    end

    def servers
      @slaves.map { |slave|
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
      @zones.map { |zone|
        "zone \"#{zone}\" { type #{role}; #{:master == role ? file(zone) : masters } };"
      }
    end
  end
end
