Deco::Application.routes.draw do
  get "user_environment/index"

#  get "user_management/index"

  resources :user_management, :except => ['show', 'new', 'create', 'update', 'edit', 'destroy'] do
    get :index, :on => :collection
    get :show_moderate, :on => :collection
  end

  resources :user_environment, :except => ['show', 'new', 'create', 'update', 'edit', 'destroy'] do
    get :index, :on => :collection
    get :edit, :on => :collection
  end

  resources :user_log, :except => ['show', 'new', 'create', 'update', 'edit', 'destroy'] do
    get :index, :on => :collection
    get :index_result, :on => :collection
    get :index_request, :on => :collection
    get :index_request_result, :on => :collection
    get :send_matter_info, :on => :collection
    get :requested_matter_info, :on => :collection
  end

  resources :address_books do
    get :index_result, :on => :collection
    get :index_sub, :on => :collection
    get :index_sub_result, :on => :collection
  end

  root :to => "top#index"
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
end
