# frozen_string_literal: true

module MCP
  module DSL
    class ServerBuilder
      def initialize
        @name = nil
        @version = nil
      end

      def build
        MCP::Server.new(name: @name, version: @version)
      end

      # standard:disable Style/TrivialAccessors
      def name(name)
        @name = name
      end

      def version(version)
        @version = version
      end
      # standard:enable Style/TrivialAccessors
    end
  end
end
