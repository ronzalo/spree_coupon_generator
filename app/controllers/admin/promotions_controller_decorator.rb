Spree::Admin::PromotionsController.class_eval do
  def automatic_load
    if params[:number_of_promos].to_i > 0
      params[:number_of_promos].to_i.times do
        @object.duplicate
      end
      flash[:success] = Spree.t(:automatic_load_success, quantity: params[:number_of_promos])
    end

    redirect_to sub_promotions_admin_promotion_path(@object) and return
  end

  def manual_load
    if params[:file]
      CSV.foreach(params[:file].path, headers: true) do |coupon|
        @object.duplicate(coupon)
      end
    end
    flash[:success] = Spree.t(:manual_load_success)
    redirect_to sub_promotions_admin_promotion_path(@object) and return
  end

  def bulk_load;end

  def export_promotions
    redirect_to edit_admin_promotion_path(@object) unless @object.is_master?

    coupon_csv = CSV.generate do |csv|
      csv << [Spree.t(:coupon)]
      @object.children.each do |promo|
        csv << [promo.code.to_s]
      end
    end

    respond_to do |format|
      format.csv { send_data coupon_csv }
    end
  end

  def collection
    return @collection if defined?(@collection)
    params[:q] ||= HashWithIndifferentAccess.new
    params[:q][:s] ||= 'id desc'

    @collection = super
    @search = @collection.only_master.ransack(params[:q])
    @collection = @search.result(distinct: true).
                  includes(promotion_includes).
                  page(params[:page]).
                  per(params[:per_page] || Spree::Config[:promotions_per_page])

    @collection
  end

  def sub_promotions
    params[:q] ||= HashWithIndifferentAccess.new
    params[:q][:s] ||= 'id desc'
    params[:q][:parent_id_eq] = @promotion.id

    @search = Spree::Promotion.ransack(params[:q])
    @promotions = @search.result(distinct: true).
                  includes(promotion_includes).
                  page(params[:page]).
                  per(params[:per_page] || Spree::Config[:promotions_per_page])

    @promotions
  end
end
