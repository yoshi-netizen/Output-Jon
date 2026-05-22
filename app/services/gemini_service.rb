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
      あなたは思考の言語化支援サービスです。
      ユーザーは自身の思考整理を試みますが、難しい場合は「AI生成」ボタンを押します。
      ボタンが押されるとあなたに【入力情報】が送られるので、ユーザーに代わって【入力情報】をもとに思考を整理したドラフトを生成してください。


      【入力情報】
      - 整理したいテーマ: #{topic}
      - 断片的な思考、思考の拡散: #{diffusion}
      - 整理する目的: #{core}

      【出力ルール】
        - ユーザー自身の言葉として出力してください。
        - 「今の〇〇を整理しました。」のような前置きは不要です。
        - 余計なアドバイスは不要です。
        - 対話型サービスではないので、出力内容内で確認や提案はしないでください。
        - プレーンテキストで出力し、マークダウン記法（# や *）は使わないでください。
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
