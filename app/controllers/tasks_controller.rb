class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [ :show, :edit, :update, :destroy ]


  def new
    @task = current_user.tasks.build
    # new画面では見積もり項目のバリデーションをスキップ
    @task.skip_estimates_validation = true
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      # AI分解処理（後で実装、今はダミーデータ）
      create_dummy_subtasks(@task)
      redirect_to task_path(@task)
    else
      render :new
    end
  end

  def index
    @tasks = current_user.tasks
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  # AI分解処理（ダミーデータ使用）
  def breakdown
    @task = current_user.tasks.build(task_params)
    # breakdown画面でも一旦スキップ（基本項目のみチェック）
    @task.skip_estimates_validation = true

    @task.assign_attributes(dummy_data[:task])
  end

  # 分解結果から実際にタスクを作成
  def create_from_breakdown
    @task = current_user.tasks.build(task_params)
    # 最終保存時は全項目のバリデーションを実行
    @task.skip_estimates_validation = false

    if @task.save
      redirect_to tasks_path, notice: "タスクが作成されました！"
    else
      Rails.logger.debug "🐻‍❄️Task validation errors: #{@task.errors.full_messages}"
      render :breakdown, status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  # ダミーデータ設定メソッド
  def dummy_data
    {
  "task": {
    "name": "サンプルタスク",
    "description_for_ai": "AI分解用のサンプルタスク説明",
    "due_date": "2025-12-29",
    "daily_task_time": 120,
    "estimate_min_days": 3,
    "estimate_normal_days": 5,
    "estimate_max_days": 8,
    "priority": "medium",
    "status": "not_started",
    "created_at": "2024-12-01T10:00:00Z",
    "updated_at": "2024-12-01T10:00:00Z"
  }
}
  end

  def task_params
  params.require(:task).permit(:id, :name, :description_for_ai, :status, :priority,
                              :daily_task_time, :estimate_min_days, :estimate_normal_days,
                              :estimate_max_days, :calculated_estimated_days, :due_date,
                              sub_tasks_attributes: [
                              :id, :name, :status, :priority, :_destroy,
                              steps_attributes: [ :id, :name, :status,
                              :due_date, :priority, :position, :_destroy ] ])
  end
end
