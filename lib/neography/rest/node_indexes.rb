module Neography
  class Rest
    module NodeIndexes
      include Neography::Rest::Helpers

      def list_node_indexes
        @connection.get("/index/node")
      end

      def create_node_index(name, type = "exact", provider = "lucene", extra_config = nil)
        config = {
          :type => type,
          :provider => provider
        }
        config.merge!(extra_config) unless extra_config.nil?
        options = {
          :body => (
            { :name => name,
              :config => config
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post("/index/node", options)
      end

      def create_node_auto_index(type = "exact", provider = "lucene")
        create_node_index("node_auto_index", type, provider)
      end

      def add_node_to_index(index, key, value, id, unique = false)
        options = {
          :body => (
            { :uri   => @connection.configuration + "/node/#{get_id(id)}",
              :key   => key,
              :value => value
            }
          ).to_json,
          :headers => json_content_type
        }
        path = unique ? "/index/node/%{index}?unique" % {:index => index} : "/index/node/%{index}" % {:index => index}
        @connection.post(path, options)
      end

      def get_node_index(index, key, value)
        index = @connection.get("/index/node/%{index}/%{key}/%{value}" % {:index => index, :key => key, :value => encode(value)}) || []
        return nil if index.empty?
        index
      end

      def find_node_index(index, key_or_query, value = nil)
        if value
          index = find_node_index_by_key_value(index, key_or_query, value)
        else
          index = find_node_index_by_query(index, key_or_query)
        end
        return nil if index.empty?
        index
      end

      def find_node_index_by_key_value(index, key, value)
        @connection.get("/index/node/%{index}/%{key}/%{value}" % {:index => index, :key => key, :value => encode(value)}) || []
      end

      def find_node_index_by_query(index, query)
        @connection.get("/index/node/%{index}?query=%{query}" % {:index => index, :query => encode(query)}) || []
      end

      # Mimick original neography API in Rest class.
      def remove_node_from_index(index, id_or_key, id_or_value = nil, id = nil)
        if id
          remove_node_index_by_value(index, id, id_or_key, id_or_value)
        elsif id_or_value
          remove_node_index_by_key(index, id_or_value, id_or_key)
        else
          remove_node_index_by_id(index, id_or_key)
        end
      end

      def remove_node_index_by_id(index, id)
        @connection.delete("/index/node/%{index}/%{id}" % {:index => index, :id => get_id(id)})
      end

      def remove_node_index_by_key(index, id, key)
        @connection.delete("/index/node/%{index}/%{key}/%{id}" % {:index => index, :id => get_id(id), :key => key})
      end

      def remove_node_index_by_value(index, id, key, value)
        @connection.delete("/index/node/%{index}/%{key}/%{value}/%{id}" % {:index => index, :id => get_id(id), :key => key, :value => encode(value)})
      end

      def drop_node_index(index)
        @connection.delete("/index/node/%{index}" % {:index => index})
      end

      def create_unique_node(index, key, value, properties = {})
        options = {
          :body => (
            { :properties => properties,
              :key => key,
              :value => value
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post("/index/node/%{index}?unique" % {:index => index}, options)
      end

      def get_or_create_unique_node(index, key, value, properties = {})
        options = {
          :body => (
            { :properties => properties,
              :key => key,
              :value => value
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post("/index/node/%{index}?uniqueness=%{function}" %  {:index => index, :function => 'get_or_create'}, options)

      end

      def create_or_fail_unique_node(index, key, value, properties = {})
        options = {
          :body => (
            { :properties => properties,
              :key => key,
              :value => value
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post("/index/node/%{index}?uniqueness=%{function}" %  {:index => index, :function => 'create_or_fail'}, options)

      end

    end
  end
end
