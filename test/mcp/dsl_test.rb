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

    def test_resource_template
      server = with_dsl do
        name "test_server" # required

        resource_template "hello://{user_name}.xml" do
          name "Hello User"
          description "A simple hello user message"
          mime_type "application/xml"
          call { |args| "<greeting>Hello, #{args[:user_name]}!</greeting>" }
        end
      end

      expected_resource_template = {
        uriTemplate: "hello://{user_name}.xml",
        name: "Hello User",
        description: "A simple hello user message",
        mimeType: "application/xml"
      }
      assert_equal [expected_resource_template], server.list_resource_templates

      content = server.read_resource("hello://alice.xml")
      assert_equal "<greeting>Hello, alice!</greeting>", content
    end

    def test_tool
      server = with_dsl do
        name "test_server" # required

        tool "greet" do
          description "Greet someone by name"
          argument :name, String, required: true, description: "Name to greet"
          call do |args|
            "Hello, #{args[:name]}!"
          end
        end
      end

      expected_tool = {
        name: "greet",
        description: "Greet someone by name",
        inputSchema: {
          type: :object,
          properties: {
            name: {
              type: :string,
              description: "Name to greet"
            }
          },
          required: [:name]
        }
      }
      assert_equal [expected_tool], server.list_tools

      tool_result = server.call_tool("greet", name: "Alice")
      assert_equal "Hello, Alice!", tool_result
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
