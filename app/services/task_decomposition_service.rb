class TaskDecompositionService
  def initialize(client: OpenAI::Client.new)
    @client = client
  end

  def call(text)
    # ここに分解ロジック
    prompt = <<~TEXT
      #{task.name}を SubTask と Step に分解してください。
      各SubTask名とStep名は簡潔で伝わりやすい名称にして下さい。
      分解するときは #{task.description_for_ai} を考慮に入れてください。
    TEXT

    task_name = params[:name]
    description_for_ai = [:description_for_ai]

    # 2. AIへの指示（プロンプト）を作成する。今回はJSON形式での出力を厳密に指示する。
    SCHEMA = {
      name: "TaskPlan",
      schema: {
        type: "object",
        additionalProperties: false,  # 余計なキーは禁止
        properties: {
          sub_tasks_attributes: {
          type: "array",
          maxItems: 4,               # 小タスクは最大4つ
          items: {
            type: "object",
            additionalProperties: false,
            properties: {
              name:    { type: "string", maxLength: 30 },
              steps_attributes: {
                type: "array",
                maxItems: 3,                             # ステップは最大3つ
                items: {
                  type: "object",
                  additionalProperties: false,
                  properties: {
                    name:    { type: "string", maxLength: 30 },
                  },
                  required: ["name"]                     # ステップ名は必須
                }
              }
            },
            required: ["name", "steps"]                  # 小タスク名とstepsは必須
          }
          }
        },
      required: ["sub_tasks"]                            # ルートにsub_tasksは必須
      }
    }

    # 4. APIにリクエストを送信する。JSONモードを有効にする。
    response = client.chat(
      parameters: {
        # model: 使用するAIモデルを指定します。
        # "gpt-4o-mini"は、高速かつ低コストでありながら高い性能を持つ最新モデルの一つです。
        model: "gpt-4o-mini",

        # messages: AIに渡す指示や会話の履歴を配列で指定します。
        # role: "user"は、ユーザーからの発言であることを示します。
        # content: ここに具体的な指示（プロンプト）を渡します。
        messages: [{ role: "user", content: prompt }],

        # response_format: AIの応答形式を指定します。
        # { type: "json_object" }とすることで、AIは必ず有効なJSONオブジェクトを返すようになります。
        response_format: { type: "json_object" },

        # temperature: 応答のランダム性（創造性）を制御します。0に近いほど決定的で、2に近いほど多様な応答になります。
        # 0.7は、ある程度の創造性を保ちつつ、安定した応答を得やすい一般的な値です。
        temperature: 0.7,
      }
    )

    # 5. AIからのJSON応答をパースし、インスタンス変数に格納する
    raw_response = response.dig("choices", 0, "message", "content")
    @recipe = JSON.parse(raw_response)
  end
  end
end