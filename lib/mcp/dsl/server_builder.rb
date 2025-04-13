# frozen_string_literal: true

module MCP
  module DSL
    class ServerBuilder
      def initialize
        @name = nil
      end

      def build
        MCP::Server.new(name: @name)
      end

      # standard:disable Style/TrivialAccessors
      def name(name)
        @name = name
      end
      # standard:enable Style/TrivialAccessors
    end
  end
end
