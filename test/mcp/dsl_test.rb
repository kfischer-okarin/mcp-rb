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

    def test_server_version
      server = with_dsl do
        name "test_server" # required
        version "1.3.9"
      end

      assert_equal "1.3.9", server.version
    end

    def test_resource
      server = with_dsl do
        name "test_server" # required

        resource "hello://world.xml" do
          name "Hello World"
          description "A simple hello world message"
          call { "<greeting>Hello, World!</greeting>" }
          mime_type "application/xml"
        end
      end

      expected_resource = {
        uri: "hello://world.xml",
        name: "Hello World",
        description: "A simple hello world message",
        mimeType: "application/xml"
      }
      assert_equal [expected_resource], server.list_resources

      content = server.read_resource("hello://world.xml")
      assert_equal "<greeting>Hello, World!</greeting>", content
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
