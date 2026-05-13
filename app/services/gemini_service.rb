require "net/http"
require "uri"
require "json"

class GeminiService
  MODEL_CODE = "gemini-3.1-flash-lite"
  ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/#{MODEL_CODE}:generateContent"

  def initialize(api_key = ENV["GEMINI_API_KEY"])
    @api_key = api_key
  end

  def call(prompt_text)
    uri = URI.parse("#{ENDPOINT}?key=#{@api_key}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
    request.body = {
      contents: [{ parts: [{ text: prompt_text }] }]
    }.to_json

    response = http.request(request)
    JSON.parse(response.body).dig("candidates", 0, "content", "parts", 0, "text")
  end
end