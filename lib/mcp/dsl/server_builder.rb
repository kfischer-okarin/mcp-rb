# frozen_string_literal: true

module MCP
  module DSL
    class ServerBuilder
      def initialize
        @name = nil
        @version = nil
      end

      def build
        @server
      end

      # standard:disable Style/TrivialAccessors
      def name(name)
        @name = name
        refresh_server
      end

      def version(version)
        @version = version
        refresh_server
      end
      # standard:enable Style/TrivialAccessors

      def resource(uri, &block)
        @server.resource(uri, &block)
      end

      def resource_template(uri_template, &block)
        @server.resource_template(uri_template, &block)
      end

      private

      def refresh_server
        @server = MCP::Server.new(name: @name, version: @version)
      end
    end
  end
end
