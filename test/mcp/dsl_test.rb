# frozen_string_literal: true

require_relative "../test_helper"

module MCP
  class DSLTest < MCPTest::TestCase
    def test_server_name
      server = with_dsl do
        name "test_server"
      end

      assert_equal "test_server", server.name
    end

    private

    def with_dsl(&block)
      mod = Module.new do
        extend DSL
        instance_eval(&block)
      end

      DSL.build_server(mod)
    end
  end
end
