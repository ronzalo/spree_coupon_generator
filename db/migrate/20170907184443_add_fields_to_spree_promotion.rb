class AddFieldsToSpreePromotion < ActiveRecord::Migration
  def change
    add_column :spree_promotions, :is_master, :boolean
    add_reference :spree_promotions, :parent, index: true
  end
end
