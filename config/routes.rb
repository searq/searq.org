# frozen_string_literal: true

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  root 'hello#index'

  get '/api', to: 'api/base#info'

  resources :hello, only: %i[index] do
    collection do
      get :download
    end
  end

  resources :exports, only: %i[index] do
    collection do
      post :download
    end
  end

  resources :stats, only: %i[index]

  resources :flows, except: %i[new edit destroy]

  namespace :api, defaults: { format: 'json' } do
    resources :feeds, except: %i[new edit destroy] do
      member do
        get :tasks
      end
      resources :items, only: %i[index show]
      collection do
        get :search
      end
    end

    resources :tokens, only: [:create] do
      collection do
        post :refresh
      end
    end

    resources :search, only: %i[index]
    resources :tasks, only: %i[index show]
  end
end
