class ItemsController < ApplicationController
  before_action :set_item, only: [:edit, :update]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update]

  def index
    @items = Item.fetch_items
  end

  def new
    # TODO:arguementerrorが出るので解消が必要
    @item = Item.new(item_params[:item][:name, :size, :condition,
                                 :postage_burden, :shipping_method, :source_area,
                                 :shipping_date, :price, :description,
                                 :category_id, :brand_name])
  end

  def create
    # 画像とブランドの保存が失敗したら処理が進まないようにtransactionを貼る
    ActiveRecord::Base.transaction do
      begin
        if @item.save!
          Item.save_item_images(item_params[:item][:item_image], @item)
          Brand.save_brand(@item, item_params[:item][:brand_name])
          redirect_to :show
        end
      rescue ::ActiveRecord::RecordNotSaved => e
        Rails.logger.debug e
        Rails.logger.warn(e)
        raise ActiveRecord::Rollback
      end
    end
  end

  def show
    #TODO:is_hosted_by?メソッドを使って、出品者以外が閲覧した際に編集ボタンが表示されないようにする。
  end

  def destroy
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to action: 'edit'
      flash[:success] = "変更しました。"
    else
      render edit
      flash[:danger] = "更新に失敗しました。"
    end
  end

  private
  def set_item
    @item = Item.fetch_item(item_params[:id])
  end
  # TODO:パラメーター受け取りのためのキーは画面実装が進んでから調整、画像は配列に入れて返してもらう、キー名はitem_image
  def item_params
    params.require(:item).permit(:name, :size, :condition,
                                 :postage_burden, :shipping_method, :source_area,
                                 :shipping_date, :price, :description,
                                 :category_id, :brand_name, :item_image)
                          .merge(user_id: current_user.id)
  end
end
