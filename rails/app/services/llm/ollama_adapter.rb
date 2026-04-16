# Llm::OllamaAdapter
#
# Sends requests to a local Ollama server running Gemma (or any other model).
# Configured via environment variables:
#   OLLAMA_HOST  — default: http://localhost:11434
#   OLLAMA_MODEL — default: gemma3:4b
#
# Ollama `/api/generate` returns a stream of JSON objects.
# We collect the full response by aggregating all "response" chunks.

require "net/http"
require "json"

module Llm
  class OllamaAdapter < AdapterBase
    TIMEOUT_SECONDS = 60

    def initialize
      @host  = ENV.fetch("OLLAMA_HOST", "http://localhost:11434")
      @model = ENV.fetch("OLLAMA_MODEL", "gemma3:4b")
    end

    def complete(prompt)
      uri  = URI("#{@host}/api/generate")
      body = { model: @model, prompt: prompt, stream: false }.to_json

      http          = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl  = uri.scheme == "https"
      http.open_timeout = TIMEOUT_SECONDS
      http.read_timeout = TIMEOUT_SECONDS

      request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      request.body = body

      response = http.request(request)

      raise "Ollama error #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body).fetch("response", "")
    rescue => e
      raise "Ollama adapter failed: #{e.message}"
    end
  end
end
