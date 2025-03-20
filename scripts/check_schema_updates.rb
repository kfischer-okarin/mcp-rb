#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

# Configuration
SPEC_REPO = "modelcontextprotocol/specification"
SCHEMA_PATH = "schema"
CURRENT_SCHEMA = "2024-11-05"

def main
  newer_schema_version = check_for_newer_schema_version

  if newer_schema_version
    set_github_output("newer_version", newer_schema_version) if running_on_github_actions?
    log "Found newer schema version: #{newer_schema_version} (current: #{CURRENT_SCHEMA})"
  else
    log "No newer schema versions found (current: #{CURRENT_SCHEMA})"
  end
rescue StandardError => e
  log "Error: #{e.message}"
  log e.backtrace.join("\n")
  exit 1
end

def check_for_newer_schema_version
  available_schema_versions = fetch_available_schema_versions
  log "Available schema versions: #{available_schema_versions.join(", ")}"

  available_schema_versions.find { |version| version > CURRENT_SCHEMA }
end

def fetch_available_schema_versions
  content_objects = fetch_github_content_objects(repository: SPEC_REPO, path: SCHEMA_PATH)

  directory_objects = content_objects.select { |entry| entry["type"] == "dir" }
  directory_names = directory_objects.map { |entry| entry["name"] }
  directory_names.delete "draft"
  directory_names
end

def fetch_github_content_objects(repository:, path:)
  uri = URI.parse("https://api.github.com/repos/#{repository}/contents/#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)
  request["Accept"] = "application/vnd.github.v3+json"

  # Use GitHub token if available for higher rate limits
  request["Authorization"] = "token #{ENV["GITHUB_TOKEN"]}" if ENV["GITHUB_TOKEN"]

  response = http.request(request)

  if response.code != "200"
    log "Error fetching directories: HTTP #{response.code}"
    log response.body
    exit 1
  end

  JSON.parse(response.body)
end

def running_on_github_actions?
  ENV["GITHUB_ACTIONS"] == "true"
end

def set_github_output(key, value)
  File.open(ENV['GITHUB_OUTPUT'], "a") do |f|
    f.puts "#{key}=#{value}"
  end
end

def log(message)
  puts "\e[32m[check_schema_updates]\e[0m #{message}"
end

main if __FILE__ == $PROGRAM_NAME