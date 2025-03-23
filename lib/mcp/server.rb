# frozen_string_literal: true

require "json"
require "English"
require "uri"
require_relative "constants"
require_relative "message_handler"
require_relative "message_validator"
require_relative "server/client_connection"
require_relative "server/stdio_client_connection"

module MCP
  class Server
    attr_writer :name, :version

    def initialize(name:, version: "0.1.0")
      @name = name
      @version = version
      @message_handler = MessageHandler.new(server_info: {name:, version:})
    end

    def name(value = nil)
      return @name if value.nil?

      @name = value
    end

    def version(value = nil)
      return @version if value.nil?

      @version = value
    end

    def initialized?
      @message_handler.initialized?
    end

    # Serve a client via the given connection.
    # This method will block while the client is connected.
    # It's the caller's responsibility to create Threads or Fibers to handle multiple clients.
    # @param client_connection [ClientConnection] The connection to the client.
    def serve(client_connection)
      loop do
        next_message = client_connection.read_next_message
        break if next_message.nil? # Client closed the connection

        response = @message_handler.handle_message(next_message)
        next unless response # Notifications don't return a response so don't send anything

        client_connection.send_message(response)
      end
    end
  end
end
