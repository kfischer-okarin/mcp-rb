# frozen_string_literal: true

module MCP
  module DSL
    class ToolBuilder
      def initialize(name)
        @name = name
        @description = nil
        @handler = nil
        @schema_builder = App::Tool::SchemaBuilder.new
      end

      def build
        validate!

        {
          name: @name,
          description: @description,
          input_schema: @schema_builder.to_schema,
          handler: @handler
        }
      end

      # standard:disable Style/TrivialAccessors
      def description(description)
        @description = description
      end

      def call(&block)
        @handler = block
      end
      # standard:enable Style/TrivialAccessors

      def argument(name, type = nil, required: false, description: "", items: nil, &block)
        @schema_builder.argument(
          name,
          type,
          required: required,
          description: description,
          items: items,
          &block
        )
      end

      private

      def validate!
        raise ArgumentError, "Tool name cannot be nil or empty" if @name.nil? || @name.empty?
        raise ArgumentError, "Handler must be provided" unless @handler
      end
    end
  end
end
