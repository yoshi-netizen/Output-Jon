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
  def call(topic:, diffusion:, core:)
    # AIへの指示（システムプロンプト）をここで定義
    prompt = <<~TEXT
      あなたは思考の言語化支援サービスです。
      ユーザーは自身の思考整理を試みますが、難しい場合は「AI生成」ボタンを押します。
      ボタンが押されるとあなたに【入力情報】が送られるので、ユーザーに代わって【入力情報】をもとに思考を整理したドラフトを生成してください。


      【入力情報】
      - 整理したいテーマ: #{topic}
      - 断片的な思考、思考の拡散: #{diffusion}
      - 整理する目的: #{core}

      【出力の構成とトーン】
      #{purpose_template(core)}

      【出力ルール】
      - ユーザー自身の言葉として出力してください。
      - 「今の〇〇を整理しました。」のような前置きは不要です。
      - 余計なアドバイスは不要です。
      - 対話型サービスではないので、出力内容内で確認や提案はしないでください。
      - プレーンテキストで出力し、マークダウン記法（# や *）は使わないでください。
      - 見出しを付ける場合は「■ 結論」のように、行頭に「■」を付けた1行にしてください。
      - 【入力情報】にない情報は補わないでください。担当者や期限なども、書かれていなければ創作しないでください。
      - 該当する内容が【入力情報】にない項目は、見出しごと省いてください。
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

  private

  # 整理の目的（Post::CORE_THINKING_TYPESの文言）に応じた、出力の構成とトーンの指示文を返す
  # 未選択（空文字）や想定外の値のときは else の汎用の指示文を返す
  def purpose_template(core)
    if core == "【報連相】 どう伝えればいいか整理したい"
      <<~TEXT
        次の順番で出力してください。
        1. 結論（伝えたいことを一文で）
        2. 現状・経緯（事実）
        3. 自分の考え・見立て
        4. 相手にお願いしたいこと
        トーン: です・ます調で簡潔に。事実と意見を分けて書いてください。
      TEXT
    elsif core == "【会議・打合せ】 決まったことと次やることを明確にしたい"
      <<~TEXT
        次の順番で出力してください。
        1. 決まったこと
        2. 次やること（誰が・いつまでに）
        3. 決まっていないこと
        トーン: 箇条書きで、短く言い切ってください。
      TEXT
    elsif core == "【学び・感想】 記事や講演の内容を自分の血肉にしたい"
      <<~TEXT
        次の順番で出力してください。
        1. 内容の要点
        2. 自分が気づいたこと・感じたこと
        3. 自分の仕事や生活にどう活かすか
        トーン: 一人称（「私は」）で、内省的に書いてください。
      TEXT
    elsif core == "【壁打ち】 モヤモヤしていることを言語化したい"
      <<~TEXT
        次の順番で出力してください。
        1. 今モヤモヤしていること（一文で）
        2. その背景・理由
        3. 現時点での自分の考え
        4. まだ答えが出ていないこと（ユーザー自身がまだ決めきれていない点として書く）
        トーン: 一人称で柔らかく。無理に結論を出さないでください。
      TEXT
    else
      <<~TEXT
        構成とトーンの指定はありません。内容に合った自然な構成で整理してください。
      TEXT
    end
  end
end
