class AddressBooksController < ApplicationController
  before_filter :authorize, :load_env
  layout "user_management"

  def index_sub
    render :layout => 'sub'
  end

  def index_sub_result
#    @recipient_number = params[:recipient_number]
    @conditions = params[:conditions]
    if @conditions[:search_select].present?
      if @conditions[:search_text].present?
        @address_books = AddressBook.where("user_id = ? AND #{@conditions[:search_select]} LIKE ? ", current_user.id, "%#{@conditions[:search_text]}%").order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
      else
        @address_books = AddressBook.where("user_id = ? AND ( #{@conditions[:search_select]} = '' OR #{@conditions[:search_select]} IS NULL )", current_user.id).order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
      end
    else
      @address_books = AddressBook.where("user_id = ? ", current_user.id).order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
    end
    render :layout => 'sub'
  end


  def index_result
#    @recipient_number = params[:recipient_number]
    @conditions = params[:conditions]
    if @conditions[:search_select].present?
      if @conditions[:search_text].present?
        @address_books = AddressBook.where("user_id = ? AND #{@conditions[:search_select]} LIKE ? ", current_user.id, "%#{@conditions[:search_text]}%").order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
      else
        @address_books = AddressBook.where("user_id = ? AND ( #{@conditions[:search_select]} = '' OR #{@conditions[:search_select]} IS NULL )", current_user.id).order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
      end
    else
      @address_books = AddressBook.where("user_id = ? ", current_user.id).order("#{@conditions[:sort_select_1]} #{t("views.sort_value.#{@conditions[:sort_select_2]}")}").page params[:page]
    end
  end

  def edit_result
    @recipient_number = params[:recipient_number]
    @address_book = AddressBook.find(params[:id])
  end

  def new_result
    @address_book = AddressBook.new
  end

  def destroy_result
    @address_book = AddressBook.find(params[:id])
  end

  # GET /address_books
  # GET /address_books.json
  def index
    @address_books = current_user.address_books.order("email ASC").page params[:page]
#    @address_books = AddressBook.all.page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @address_books }
    end
  end

  # GET /address_books/1
  # GET /address_books/1.json
  def show
    @address_book = AddressBook.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @address_book }
    end
  end

  # GET /address_books/new
  # GET /address_books/new.json
  def new
    @address_book = AddressBook.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @address_book }
    end
  end

  # GET /address_books/1/edit
  def edit
    @address_book = AddressBook.find(params[:id])
  end

  # POST /address_books
  # POST /address_books.json
  def create
    @address_book = AddressBook.new(params[:address_book])
    @address_book.user_id = session[:user_id] unless session[:user_id].blank?
    respond_to do |format|
      if @address_book.save
        format.html { redirect_to @address_book, notice: t("address_books.create.message") }
        format.json { render json: @address_book, status: :created, location: @address_book }
      else
        format.html { render action: "new" }
        format.json { render json: @address_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /address_books/1
  # PUT /address_books/1.json
  def update
    @address_book = AddressBook.find(params[:id])
    respond_to do |format|
      if @address_book.update_attributes(params[:address_book])
#        format.html { redirect_to '/address_books/index_result/?recipient_address=1', notice: 'Address book was successfully updated.' }
        format.html { redirect_to @address_book, notice: t("address_books.update.message") }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @address_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /address_books/1
  # DELETE /address_books/1.json
  def destroy
    @address_book = AddressBook.find(params[:id])
    @address_book.destroy

    respond_to do |format|
      format.html { redirect_to address_books_url }
      format.json { head :no_content }
    end
  end
end
