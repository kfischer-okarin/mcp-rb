# frozen_string_literal: true

module MCP
  module DSL
    class ToolBuilder
      def initialize(name)
        @name = name
        @description = nil
        @handler = nil
        @schema_builder = SchemaBuilder.new
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

      # Builds schemas for arguments, supporting simple types, nested objects, and arrays
      class SchemaBuilder
        def initialize
          @schema = nil
          @properties = {}
          @required = []
        end

        def argument(name, type = nil, required: false, description: "", items: nil, &block)
          if type == Array
            if block_given?
              sub_builder = SchemaBuilder.new
              sub_builder.instance_eval(&block)
              item_schema = sub_builder.to_schema
            elsif items
              item_schema = {type: ruby_type_to_schema_type(items)}
            else
              raise ArgumentError, "Must provide items or a block for array type"
            end
            @properties[name] = {type: :array, description: description, items: item_schema}
          elsif block_given?
            raise ArgumentError, "Type not allowed with block for objects" if type
            sub_builder = SchemaBuilder.new
            sub_builder.instance_eval(&block)
            @properties[name] = sub_builder.to_schema.merge(description: description)
          else
            raise ArgumentError, "Type required for simple arguments" if type.nil?
            @properties[name] = {type: ruby_type_to_schema_type(type), description: description}
          end
          @required << name if required
        end

        def type(t)
          @schema = {type: ruby_type_to_schema_type(t)}
        end

        def to_schema
          @schema || {type: :object, properties: @properties, required: @required}
        end

        private

        def ruby_type_to_schema_type(type)
          if type == String
            :string
          elsif type == Integer
            :integer
          elsif type == Float
            :number
          elsif type == TrueClass || type == FalseClass
            :boolean
          elsif type == Array
            :array
          else
            raise ArgumentError, "Unsupported type: #{type}"
          end
        end
      end

      private

      def validate!
        raise ArgumentError, "Tool name cannot be nil or empty" if @name.nil? || @name.empty?
        raise ArgumentError, "Handler must be provided" unless @handler
      end
    end
  end
end
