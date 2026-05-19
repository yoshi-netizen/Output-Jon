require "net/http"
require "uri"
require "json"

class GeminiService
  MODEL_CODE = "gemini-3.1-flash-lite"
  ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/#{MODEL_CODE}:generateContent"

  def initialize(api_key = ENV["GEMINI_API_KEY"])
    @api_key = api_key
  end

  # 引数を個別に受け取り、プロンプトを組み立てる
  def call(topic, diffusion, core)
    # AIへの指示（システムプロンプト）をここで定義
    prompt = <<~TEXT
      あなたは思考の編集者です。以下の情報を整理し、ユーザーが納得できる論理的な文章にまとめてください。

      【入力情報】
      - テーマ: #{topic}
      - 広がった思考: #{diffusion}
      - 核心部分: #{core}

      【出力ルール】
      ・結論から述べ、簡潔かつ深く掘り下げた内容にすること。
      ・余計な挨拶は不要です。
    TEXT

    uri = URI.parse("#{ENDPOINT}?key=#{@api_key}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, { "Content-Type" => "application/json" })
    request.body = {
      contents: [ { parts: [ { text: prompt } ] } ]
    }.to_json

    response = http.request(request)

    if response.code == "200"
      JSON.parse(response.body).dig("candidates", 0, "content", "parts", 0, "text")
    else
      "エラーが発生しました: #{response.code}"
    end
  end
end
