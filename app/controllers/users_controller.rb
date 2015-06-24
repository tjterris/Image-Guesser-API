class UsersController < ApplicationController
  # before_action :authenticate_user!, only: [:delete]
  ## authenticate_user! is a devise method.  must fix this.

  def create
    passhash = Digest::SHA1.hexdigest(params[:password])
    @user = User.new(email: params[:email],
                     password: passhash,
                     full_name: params[:full_name],
                     username: params[:username])
    if @user.save
      # render json "register.json.jbuilder", status: :created
      render json: { user: @user.as_json(only: [:email, 
                                                :access_token, 
                                                :full_name, 
                                                :username, 
                                                :id,
                                                :total_points]) },
        status: :created
    else
      render json: { errors: @user.errors.full_messages },
        status: :unprocessable_entity
    end
  end

  def login
    passhash = Digest::SHA1.hexdigest(params[:password])
    @user = User.find_by(password: passhash,
                         username: params[:username])
    if @user
      # render json "register.json.jbuilder", status: :created
      render json: { user: @user.as_json(only: [:email,
                                                :access_token,
                                                :full_name, 
                                                :username,
                                                :id]) },
        status: :ok
    else
      render json: { message: 'No matching username or password found.' },
        status: :not_found
    end
  end

  def show
    @user = User.find_by(id: params[:id])
    if @user
      # render json "register.json.jbuilder", status: :created
      render json: { user: @user.as_json(only: [:email,
                                                :full_name, :username,
                                                :id]) },
        status: :ok
    end
  end

  def index
    @users = User.all
    render json: { users: @users.as_json(only: [:email, :full_name, :username, :id]) },
    status: :ok
  end

  def scoreboard
    @users = User.order(total_points: :desc).limit(5)
  end

  def delete
    @user = User.find(params[:username])
    if current_user.access_token == @user.access_token
      @user.destroy
      render json: { message: 'User has been deleted'},
      status: :ok
    else
      render json: { message: 'Only the user can delete his/her own account.' },
        status: :unauthenticated
    end
    # redirect_to posts_path
  end

end