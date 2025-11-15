class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :finalize, :breakdown_result ]


  def new
    @task = current_user.tasks.build
    # new画面では見積もり項目のバリデーションをスキップ
    @task.skip_estimates_validation = true
  end

  def create
    @task = current_user.tasks.build(task_params)
    @task.draft = true
    @task.skip_estimates_validation = true

    Task.transaction do
      @task.save!                               # まず Task をドラフト保存
    end

    render :breakdown_result                    # 分解結果の表示画面へ
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end


  def index
    @tasks = current_user.tasks
  end

  def show
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "タスクを更新しました。"
    else
      flash.now[:alert] = @task.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ActiveRecord::Base.transaction do                        # 失敗時にDB変更を元に戻すためのトランザクション開始
      @task.destroy!
    end

    redirect_to user_root_path,                                  # 正常に削除できたら一覧へ
                notice: "タスクを削除しました。"               # 画面上部に通知メッセージを表示
  rescue ActiveRecord::RecordNotDestroyed => e               # destroy! が失敗した場合（コールバックで :abort 等）
    flash.now[:alert] =                                      # エラーメッセージをその場表示用にセット
      @task.errors.full_messages.to_sentence.presence ||"タスクの削除に失敗しました。"
    render :edit, status: :unprocessable_entity
  end

  # AI分解処理（分解ボタン → 仮保存（ドラフト）
  def breakdown
    @task = current_user.tasks.build(task_params)
    # breakdown画面でも一旦スキップ（基本項目のみチェック）
    @task.skip_estimates_validation = true
    Rails.logger.debug params.inspect
    # ダミーデータを割り当て
    # @task.assign_attributes(dummy_data[:task])

    decomposition_task = TaskDecompositionService.new.call(@task)  # => { task: { sub_tasks_attributes: [...] } }
    @task.assign_attributes(decomposition_task[:task])

    if @task.save
      # 保存に成功したら分解結果画面へ
      redirect_to breakdown_result_task_path(@task)
    else
      # 保存に失敗したら new.html.erb を再表示
      flash.now[:alert] = @task.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  # 分解結果の編集 → 本保存（ドラフト解除）
  def finalize
    @task.skip_estimates_validation = false
    if @task.update(task_params.merge(draft: false))
      redirect_to tasks_path, notice: "タスクを登録しました！"
    else
      flash.now[:alert] = @task.errors.full_messages.to_sentence
      render :breakdown_result, status: :unprocessable_entity
    end
  end

  # 分解結果のドラフト破棄
  def discard
    task = current_user.tasks.find(params[:id])
    task.destroy!

    # 破棄したタスクページの履歴を残さない
    response.set_header("Turbo-Visit-Action", "replace")

    redirect_to new_task_path, notice: "下書きを破棄しました。"
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    redirect_to new_task_path, alert: "その下書きは見つかりません（破棄済みの可能性があります）。"
  end

  # ダミーデータ設定メソッド
  def dummy_data
  {
    task: {
      # SubTasks を追加
      sub_tasks_attributes: [
        {
          name: "要件定義・設計",
          steps_attributes: [
            { name: "ユーザー認証の要件整理" },
            { name: "データベース設計" },
            { name: "UI設計" }
          ]
        },
        {
          name: "バックエンド実装",
          steps_attributes: [
            { name: "ユーザーモデルの作成" },
            { name: "認証コントローラーの実装" },
            { name: "セッション管理の実装" }
          ]
        },
        {
          name: "フロントエンド実装",
          steps_attributes: [
            { name: "ログイン画面の作成" },
            { name: "新規登録画面の作成" },
            { name: "ユーザー情報画面の作成" }
          ]
        },
        {
          name: "テスト・デバッグ",
          steps_attributes: [
            { name: "単体テストの作成" },
            { name: "統合テストの実施" },
            { name: "バグ修正・調整" }
          ]
        }
      ]
    }
  }
end

  def task_params
  params.require(:task).permit(:id, :name, :description_for_ai, :status, :priority,
                              :daily_task_time, :estimate_min_days, :estimate_normal_days,
                              :estimate_max_days, :calculated_estimated_days, :due_date,
                              sub_tasks_attributes: [
                              :id, :name, :status, :_destroy,
                              steps_attributes: [ :id, :name, :status,
                              :due_date, :priority, :_destroy ] ])
  end
end
