module Bindurator
  class View
    def initialize name, data
      raise "data should include clients, masters, slaves and zones lists" unless
        data.is_a?(Hash) && [:clients, :masters, :slaves, :zones].all? { |k| data.has_key?(k) && data[k].is_a?(Array) }

      @name = name
      @clients = data[:clients]
      @masters = data[:masters]
      @slaves = data[:slaves]
      @zones = data[:zones]
    end

    def slave
      ["view \"#{@name}\" {",
        [clients, zones(:slave)].flatten.join("\n"),
      "};\n"].join("\n")
    end

    def master
    end

    private

    def clients
      "match-clients { key #{@name}, !tsig_keys, #{@clients.join(", ")} };"
    end

    def masters
      "masters { #{@masters.reduce("") { |a, e| "%s key %s;" % [e, @name]} } };"
    end

    def file zone
      "file \"pri/#{zone}/#{@name}.zone\";"
    end

    def zones role
      @zones.map { |zone|
        "zone \"#{zone}\" { type #{role}; #{:master == role ? file(zone) : masters } };"
      }
    end
  end
end