class TaskDecompositionService
  MAX_OUTPUT_TOKENS = 300
  MAX_RETRIES       = 2    # 最大リトライ数
  MAX_DESC_CHARS    = 100  # AI用説明文の最大文字数

  # JSON形式での出力を厳密に指示する。
  RESPONSE_SCHEMA = {
        type: "object",
        additionalProperties: false,  # 余計なキーは禁止
        properties: {
          task: {
          type: "object",
          additionalProperties: false,
            properties: {
              sub_tasks_attributes: {
              type: "array",
              maxItems: 4,               # 小タスクは最大4つ
              items: {
                type: "object",
                additionalProperties: false,
                properties: {
                  name:    { type: "string", maxLength: 20 },
                  steps_attributes: {
                    type: "array",
                    maxItems: 3,                             # ステップは最大3つ
                    items: {
                      type: "object",
                      additionalProperties: false,
                      properties: {
                        name:    { type: "string", maxLength: 20 }
                      },
                      required: [ "name" ]                     # ステップ名は必須
                    }
                  }
                },
                required: [ "name", "steps_attributes" ]                  # 小タスク名とstepsは必須
              }
              }
            },
            required: [ "sub_tasks_attributes" ]                            # ルートにsub_tasksは必須
          }
        },
        required: [ "task" ]
      }.freeze


  def initialize(client: OpenAI::Client.new(request_timeout: 10))
    @client = client
  end

  # タスク分解ロジック
  def call(task)
    prompt = build_prompt(task)
    raw_response = nil

    # APIにリクエストを送信する。JSONモードを有効にする。
    response = with_retry do
      @client.chat(
        parameters: {
          # model: 使用するAIモデルを指定
          model: "gpt-4o-mini",

          # messages: AIに渡す指示や会話の履歴を配列で指定
          # role: "user"は、ユーザーからの発言であることを示す
          # content: ここに具体的な指示（プロンプト）を渡す
          messages: [
            { role: "system", content: "提供されたスキーマに厳密に準拠したJSONのみを出力します。説明文、文章、マークダウンは一切含まれません。" },
            { role: "user", content: prompt }
          ],

          # response_format: AIの応答形式を指定
          # { type: "json_schema" }とすることで、AIは必ず有効なJSONオブジェクトを返すようになる
          response_format: {
            type: "json_schema",
            json_schema: { name: "TaskPlan", schema: RESPONSE_SCHEMA, strict: true }
          },

          # temperature: 応答のランダム性（創造性）を制御。（0に近いほど決定的で、2に近いほど多様な応答）
          # 0.7は、ある程度の創造性を保ちつつ、安定した応答を得やすい一般的な値
          temperature: 0.7,
          max_tokens: MAX_OUTPUT_TOKENS,
          n: 1
        }
      )
    end

    finish = response.dig("choices", 0, "finish_reason")
    Rails.logger.warn("[AI WARN] finish_reason=length (hit max_tokens)") if finish == "length"

    raw_response = response.dig("choices", 0, "message", "content")
    raise "AI応答が空です" if raw_response.blank?

    decomposition_task = JSON.parse(raw_response, symbolize_names: true)
    decomposition_task  # メソッドの返り値

  rescue JSON::ParserError => e
    Rails.logger.error("JSON parse error: #{e.message} / raw=#{raw_response&.truncate(200)}")
    raise
  ensure
    # 使用量を記録（コストの見える化）
    usage = response && response["usage"]
    Rails.logger.info do
      <<~LOG
        [AI USAGE]
        prompt=#{usage&.dig('prompt_tokens')}
        completion=#{usage&.dig('completion_tokens')}
        total=#{usage&.dig('total_tokens')}
      LOG
    end
  end

  private

  def build_prompt(task)
    desc = task.description_for_ai.to_s.strip[0, MAX_DESC_CHARS]
    <<~TEXT
      「#{task.name}」を SubTask と Step に分解してください。
      #{desc.empty? ? "" : "追加考慮: #{desc}"}
      出力は指定スキーマに厳密準拠。余計な説明は不要。
    TEXT
  end

  def with_retry
    attempts = 0
    begin
      yield
    rescue OpenAI::Error => e
      code = e.response.dig("status").to_i rescue nil
      retryable = (code == 429) || (500..599).include?(code)
      raise unless retryable && (attempts += 1) <= MAX_RETRIES
      sleep(2 ** attempts)
      retry
    end
  end
end
