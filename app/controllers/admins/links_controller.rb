class Admins::LinksController < ApplicationController
  before_action :set_link, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:index, :show]
  before_action :authorized_user, only: [:edit, :update, :destroy]

  def index
    @links = Link.all
  end

  def show
  end

  def new
    @link = current_user.links.build
  end

  def edit
  end

  def create
    @link = current_user.links.build(link_params)
    if @link.save
      redirect_to admins_link_path(@link), notice: 'Link was successfully created.'
    else
      render :new
    end
  end

  def update
    if @link.update(link_params)
      redirect_to admins_link_path(@link), notice: 'Link was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @link.destroy
    redirect_to admins_links_url, notice: 'Link was successfully destroyed.'
  end

  private
    def set_link
      @link = Link.find(params[:id])
    end

    def authorized_user
      @link = current_user.links.find_by(id: params[:id])
      redirect_to admins_links_path, notice: "Not authorized to manage this link." if @link.nil?
    end

    def link_params
      params.require(:link).permit(:title, :url)
    end
end
