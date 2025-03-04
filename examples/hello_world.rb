#!/usr/bin/env ruby
# frozen_string_literal: true
require "httparty"
require_relative "../lib/mcp"

name "hello-world"
version "1.0.0"

tool "greet" do
  description "Greet someone by name"
  argument :name, String, required: true, description: "Name to greet"

  call do |args|
    "Hello, #{args[:name]}!"
  end
end

resource "hello://world" do
  name "Hello World"
  description "A simple hello world message"
  mime_type "text/plain"
  call { "Hello, World!" }
end

resource_template "users://{user_name}" do
  name "Hello User"
  description "Template for accessing user resources by name"
  mime_type "application/json"
  call do |args|
    # The variables hash contains the extracted values from the URI
    # For example, if URI is "hello://123", then variables = {"user_name" => "123"}
    user_name = args[:user_name]
    "Hello #{user_name}!"
  end
end

# Example with multiple variables
resource_template "users://{user_name}/posts/{post_id}" do
  name "User Post"
  description "Template for accessing user posts by user name and post ID"
  mime_type "application/json"
  call do |args|
    user_name = args[:user_name]
    post_id = args[:post_id]
    "Hello #{user_name}! I see your post #{post_id}"
 end
end