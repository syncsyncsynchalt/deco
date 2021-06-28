Rails.application.routes.draw do

  resources :top

  resources :sessions do
    get :destroy, :on => :collection
    get :new_for_administrator, :on => :collection
    get :login_for_administrator, :on => :collection
    post :login_for_administrator, :on => :collection
    get :logout_for_administrator, :on => :collection
    post :logout_for_administrator, :on => :collection
    get :change_parameter, :on => :collection
  end

  resources :receiver_list_import do
    post :show, :on => :collection
    get :dummy_action, :on => :collection
  end

  get 'file_send/result/:id', to: 'file_send#result'
  resources :file_send do
    get :noflash, :on => :collection
    get :index_flash, :on => :collection
    get :index_noflash, :on => :collection
    post :upload, :on => :collection
    post :upload5, :on => :collection
    get :send_ng, :on => :collection
    post :create_noflash, :on => :collection
    get :login, :on => :collection
    get :auth, :on => :collection
    post :auth, :on => :collection
    get :result, :on => :collection
    get :result_ng, :on => :collection
    get :delete, :on => :collection
    get :message, :on => :collection
  end

  get 'file_receive/login/:id', to: 'file_receive#login'
  resources :file_receive do
    get :login, :on => :collection
    post :auth, :on => :collection
    get :get, :on => :collection
    get :message, :on => :collection
    get :illegal, :on => :collection
  end

  get 'file_send_moderate/index/:id', to: 'file_send_moderate#index'
  get 'file_send_moderate/login/:id', to: 'file_send_moderate#login'
  get 'file_send_moderate/approval/:id', to: 'file_send_moderate#approval'
  get 'file_send_moderate/new/:id', to: 'file_send_moderate#new'
  resources :file_send_moderate do
    get :login, :on => :collection
    post :auth, :on => :collection
    get :get, :on => :collection
    get :approval, :on => :collection
    get :message, :on => :collection
  end

  get 'file_request/result/:id', to: 'file_request#result'
  resources :file_request do
    get :result, :on => :collection
    get :result_ng, :on => :collection
    get :login, :on => :collection
    post :auth, :on => :collection
    get :message, :on => :collection
  end

  get 'file_request_moderate/index/:id', to: 'file_request_moderate#index'
  get 'file_request_moderate/login/:id', to: 'file_request_moderate#login'
  get 'file_request_moderate/approval/:id', to: 'file_request_moderate#approval'
  get 'file_request_moderate/new/:id', to: 'file_request_moderate#new'
  resources :file_request_moderate do
    get :login, :on => :collection
    post :auth, :on => :collection
    get :get, :on => :collection
    get :approval, :on => :collection
    get :message, :on => :collection
  end

  get 'requested_file_send/login/:id', to: 'requested_file_send#login'
  get 'requested_file_send/blank/:id', to: 'requested_file_send#blank'
  get 'requested_file_send/result/:id', to: 'requested_file_send#result'
  get 'requested_file_send/delete/:id', to: 'requested_file_send#delete'
  post 'requested_file_send/delete/:id', to: 'requested_file_send#delete'
  resources :requested_file_send do
    get :login, :on => :collection
    post :auth, :on => :collection
    get :index_flash, :on => :collection
    get :noflash, :on => :collection
    get :index_noflash, :on => :collection
    post :upload, :on => :collection
    post :upload5, :on => :collection
    get :send_ng, :on => :collection
    post :create_noflash, :on => :collection
    get :result, :on => :collection
    get :delete, :on => :collection
    post :delete, :on => :collection
    get :result_ng, :on => :collection
    get :blank, :on => :collection
    get :message, :on => :collection
  end

  get 'requested_file_receive/login/:id', to: 'requested_file_receive#login'
  resources :requested_file_receive do
    get :login, :on => :collection
    post :auth, :on => :collection
    get :get, :on => :collection
    get :blank, :on => :collection
    get :message, :on => :collection
  end

  get 'content/load/:id', to: 'content#load'
  resources :content do
  end

  get 'user_management/show_moderate/:id', to: 'user_management#show_moderate'
  resources :user_management do
    get :show_moderate, :on => :collection
  end

  resources :user_environment do
    get :edit, :on => :collection
  end

  resources :address_books do
    get :index_result, :on => :collection
    get :index_sub, :on => :collection
    get :index_sub_result, :on => :collection
    get :edit_result, :on => :collection
#    index_sub_result
  end

  get 'user_log/send_matter_info/:id', to: 'user_log#send_matter_info'
  get 'user_log/requested_matter_info/:id', to: 'user_log#requested_matter_info'
  resources :user_log do
    get :index_request, :on => :collection
    get :index_result, :on => :collection
    get :index_request_result, :on => :collection
    get :send_matter_info, :on => :collection
    get :requested_matter_info, :on => :collection
  end

  resources :sys_top do
    get :init_permit_ip, :on => :collection
    post :param_create, :on => :collection
    get :param_edit1, :on => :collection
    patch :param_update, :on => :collection
    delete :param_destroy, :on => :collection
  end

  resources :sys_announcement do
  end

  resources :sys_param do
    get :common_index, :on => :collection
    get :common_index2, :on => :collection
    get :user_type_index, :on => :collection
    get :create, :on => :collection
    post :create_term, :on => :collection
    get :create2, :on => :collection
    post :create2, :on => :collection
    get :edit1_only_num, :on => :collection
    get :edit1, :on => :collection
    get :edit2, :on => :collection
    patch :update, :on => :collection
    post :update_term, :on => :collection
    get :update2, :on => :collection
    post :update2, :on => :collection
    patch :update2, :on => :collection
  end

  resources :sys_user do
    get :chg_pw, :on => :collection
    get :chg_moderate, :on => :collection
    get :chg_moderate, :on => :collection
  end

  resources :user do
    get :pw_update, :on => :collection
    post :pw_update, :on => :collection
  end

  resources :sys_moderate do
  end

  get 'sys_content/edit_item/:id', to: 'sys_content#edit_item'
  resources :sys_content do
    get :change_expression, :on => :collection
    get :edit_page, :on => :collection
    patch :update_content_frame, :on => :collection
    get :add_subpage, :on => :collection
    get :delete_page, :on => :collection
    get :edit_title, :on => :collection
    get :edit_description, :on => :collection
    get :edit_item, :on => :collection
    post :edit_item, :on => :collection
    post :register_item, :on => :collection
    delete :delete_item, :on => :collection
  end

  get 'create_images/content_items/:id', to: 'create_images#content_items'
  resources :create_images do
    get :content_items, :on => :collection
  end

  resources :sys_data do
    get :get_send_file, :on => :collection
    get :get_requested_file, :on => :collection
  end

  get 'sys_log/send_matter_info/:id', to: 'sys_log#send_matter_info'
  get 'sys_log/requested_matter_info/:id', to: 'sys_log#requested_matter_info'
  resources :sys_log do
    get :send_log, :on => :collection
    post :get_csv_of_send_log, :on => :collection
    get :send_matter_info, :on => :collection
    get :receive_log, :on => :collection
    post :get_csv_of_receive_log, :on => :collection
    get :request_log, :on => :collection
    post :get_csv_of_request_log, :on => :collection
  end

  resources :sys_total do
  end

  root :to => "top#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
