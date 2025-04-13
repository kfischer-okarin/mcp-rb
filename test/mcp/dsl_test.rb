# frozen_string_literal: true

require_relative "../test_helper"

module MCP
  class DSLTest < MCPTest::TestCase
    def test_server_name
      mod = Module.new do
        extend DSL

        name "test_server"
      end

      server = DSL.build_server(mod)

      assert_equal "test_server", server.name
    end
  end
end
