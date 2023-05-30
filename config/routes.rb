Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :google_sheets

  resources :timesheet_crons, only: [] do
    collection do
      get :accounts
      post :import_data
    end
  end
end
