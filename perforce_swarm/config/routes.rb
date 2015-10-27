Rails.application.routes.draw do
  devise_scope :user do
    get 'user/recent_projects' => 'application#load_user_projects'
  end

  resources :namespaces, path: '/', constraints: { id: /[a-zA-Z.0-9_\-]+/ }, only: [] do
    resources(:projects, constraints: { id: /[a-zA-Z.0-9_\-]+(?<!\.atom)/ }, only:
                           [:configure_mirroring, :enable_mirroring], path: '/') do
      member do
        get :configure_mirroring
        post :enable_mirroring
      end
    end
  end

  namespace :perforce_swarm,  path: '/gitswarm' do
    resource :git_fusion, only: [], controller: :git_fusion do
      get :new_project
      get :existing_project
    end
  end
end
