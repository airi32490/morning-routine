class HealthsController < ApplicationController
  before_action :search_health, only: [:search, :result]

  def index
  end

  def new
    @health = Health.new
  end

  def create
    @health = Health.new(health_params)
    if@health.save
      if (@health.body_temperature >= 37.0) || (@health.alcohol_level >= 0.15) || (@health.condition_id == 4)
        redirect_to check_healths_path
      else
        redirect_to top_healths_path
      end
    else
      render :new
    end
  end

  def check
    @healths = Health.all.order(created_at: :desc)
    @user = User.new
  end

  def approval
    @user = User.find_by(health_checker_params)
    if @user != nil
      if @user.id == current_user.id
        flash[:error] = "他の資格保有者が承認を行なってください"
        redirect_to check_healths_path
      elsif @user.checker_id == 2
        redirect_to top_healths_path
      else
        flash[:error] = "資格保有者のメールアドレスを入力してください"
        redirect_to check_healths_path
      end
    else
      flash[:error] = "確認者のメールアドレスを入力してください"
      redirect_to check_healths_path
    end
  end

  def top
  end

  def search
    # @healths = Health.all
    set_user_column
    set_health_column
    # @users = User.all
  end

  def result
    @results = @h.result.includes(:user)
  end


  private

  def health_params
    params.require(:health).permit(:body_temperature, :condition_id, :alcohol_level).merge(user_id: current_user.id)
  end

  def health_checker_params
    params.require(:user).permit(:email)
  end

  def search_health
    @h = Health.ransack(params[:q])
    # @u = User.ransack(params[:q])
  end

  def set_user_column
    @user_name = User.select("name")
  end

  def set_health_column
    @health_created_at = Health.select("created_at")
  end
end
