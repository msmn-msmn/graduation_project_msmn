Rails.application.routes.draw do
  get "sub_tasks/edit"
  get "sub_tasks/update"
  get "sub_tasks/destroy"
  get "sub_tasks/complete"
  get "sub_tasks/restart"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users,
  path: "",
  path_names: {
    sign_in: "login",
    sign_out: "logout",
    sign_up: "signup"
  }

  resources :users, only: %i[index show edit update destroy] # new,createはDeviseから提供される
  # タスク関連（ネストしたサブタスクを含む）
  resources :tasks do
    # ネストしたサブタスク（タスクに紐づく操作）
    resources :sub_tasks, except: [ :show ] do
      member do
        patch :complete      # 完了にする
        patch :restart       # 未完了にする
      end
    end
  end

  root to: "static_pages#index"

  # ログイン後のメインページ（認証が必要）
  get "/dashboard", to: "tasks#index", as: :user_root

  get "static_pages/index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
