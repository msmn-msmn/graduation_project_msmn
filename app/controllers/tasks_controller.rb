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
      dummy_data!(@task)              # 次に SubTask / Step をダミーで作成
    end

    render :breakdown_result                    # 分解結果の編集画面へ
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
    @task.assign_attributes(dummy_data[:task])

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

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  # ダミーデータ設定メソッド
  def dummy_data
  {
    task: {
      user_id: current_user.id,
      name: "サンプルタスク",
      description_for_ai: "AI分解用のサンプルタスク説明",
      due_date: "2025-12-29",
      daily_task_time: 120,
      estimate_min_days: 3,
      estimate_normal_days: 5,
      estimate_max_days: 8,
      priority: 1,
      status: "not_started",
      # SubTasks を追加
      sub_tasks_attributes: [
        {
          position: 1,
          name: "要件定義・設計",
          steps_attributes: [
            { name: "ユーザー認証の要件整理", status: "not_started", position: 1, user_id: current_user.id },
            { name: "データベース設計",       status: "not_started", position: 2, user_id: current_user.id },
            { name: "UI設計",                 status: "not_started", position: 3, user_id: current_user.id }
          ]
        },
        {
          position: 2,
          name: "バックエンド実装",
          steps_attributes: [
            { name: "ユーザーモデルの作成",     status: "not_started", position: 1, user_id: current_user.id },
            { name: "認証コントローラーの実装", status: "not_started", position: 2, user_id: current_user.id },
            { name: "セッション管理の実装",     status: "not_started", position: 3, user_id: current_user.id }
          ]
        },
        {
          position: 3,
          name: "フロントエンド実装",
          steps_attributes: [
            { name: "ログイン画面の作成",   status: "not_started", position: 1, user_id: current_user.id },
            { name: "新規登録画面の作成",   status: "not_started", position: 2, user_id: current_user.id },
            { name: "ユーザー情報画面の作成", status: "not_started", position: 3, user_id: current_user.id }
          ]
        },
        {
          position: 4,
          name: "テスト・デバッグ",
          steps_attributes: [
            { name: "単体テストの作成",   status: "not_started", position: 1, user_id: current_user.id },
            { name: "統合テストの実施",   status: "not_started", position: 2, user_id: current_user.id },
            { name: "バグ修正・調整",     status: "not_started", position: 3, user_id: current_user.id }
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
