# frozen_string_literal: true

module MCP
  class App
    module Tool
      def tools
        @tools ||= {}
      end

      # Lists tools with pagination
      def list_tools(cursor: nil, page_size: 10)
        start = cursor ? cursor.to_i : 0
        paginated = tools.values[start, page_size]

        next_cursor = (start + page_size < tools.length) ? (start + page_size).to_s : nil
        {tools: paginated.map { |t| {name: t[:name], description: t[:description], inputSchema: t[:input_schema]} }, nextCursor: next_cursor}.compact
      end

      # Calls a tool with the provided arguments
      def call_tool(name, **args)
        tool = tools[name]
        raise ArgumentError, "Tool not found: #{name}" unless tool

        validate_arguments(tool[:input_schema], args)
        {content: [{type: "text", text: tool[:handler].call(args).to_s}], isError: false}
      rescue => e
        {content: [{type: "text", text: "Error: #{e.message}"}], isError: true}
      end

      private

      def validate(schema, arg, path = "")
        errors = []
        type = schema[:type]

        if type == :object
          if !arg.is_a?(Hash)
            errors << (path.empty? ? "Arguments must be a hash" : "Expected object for #{path}, got #{arg.class}")
          else
            schema[:required]&.each do |req|
              unless arg.key?(req)
                errors << (path.empty? ? "Missing required param :#{req}" : "Missing required param #{path}.#{req}")
              end
            end
            schema[:properties].each do |key, subschema|
              if arg.key?(key)
                sub_path = path.empty? ? key : "#{path}.#{key}"
                sub_errors = validate(subschema, arg[key], sub_path)
                errors.concat(sub_errors)
              end
            end
          end
        elsif type == :array
          if !arg.is_a?(Array)
            errors << "Expected array for #{path}, got #{arg.class}"
          else
            arg.each_with_index do |item, index|
              sub_path = "#{path}[#{index}]"
              sub_errors = validate(schema[:items], item, sub_path)
              errors.concat(sub_errors)
            end
          end
        else
          valid = case type
          when :string then arg.is_a?(String)
          when :integer then arg.is_a?(Integer)
          when :number then arg.is_a?(Float)
          when :boolean then arg.is_a?(TrueClass) || arg.is_a?(FalseClass)
          else false
          end
          unless valid
            errors << "Expected #{type} for #{path}, got #{arg.class}"
          end
        end
        errors
      end

      def validate_arguments(schema, args)
        errors = validate(schema, args, "")
        unless errors.empty?
          raise ArgumentError, errors.join("\n").to_s
        end
      end
    end
  end
end
