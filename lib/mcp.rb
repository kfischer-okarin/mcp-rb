# frozen_string_literal: true

require "English"
require "json"

require_relative "mcp/version"
require_relative "mcp/constants"
require_relative "mcp/app"
require_relative "mcp/server"
require_relative "mcp/client"
require_relative "mcp/dsl"

module MCP
  class << self
    attr_reader :server

    def initialize_server(name:, **options)
      @server ||= Server.new(name: name, **options)
    end
  end

  def self.new(**options, &block)
    @server = Server.new(**options)
    return @server if block.nil?

    if block.arity.zero?
      @server.instance_eval(&block)
    else
      (block.arity == 1) ? yield(@server) : yield
    end

    @server
  end
end

extend MCP::DSL # standard:disable Style/MixinUsage

was_required_by_app_file = caller_locations.first.absolute_path == File.absolute_path($PROGRAM_NAME)

at_exit do
  if $ERROR_INFO.nil? && was_required_by_app_file
    server = MCP::DSL.build_server(self)
    server.serve(MCP::Server::StdioClientConnection.new)
  end
end
