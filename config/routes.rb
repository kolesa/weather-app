Rails.application.routes.draw do
  root "weathers#index"

  get 'weathers/show', to: 'weathers#show', as: 'weather_show'
  resources :weathers, only: :index
end
