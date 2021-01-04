Rails.application.routes.draw do
  root to: 'visitors#index'

  get 'visitors/generate_json'
end
