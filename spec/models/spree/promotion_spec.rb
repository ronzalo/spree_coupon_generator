require 'spec_helper'

describe Spree::Promotion do
  let(:master_promotion) {create(:promotion_with_order_adjustment, is_master: true) }

  context 'as parent' do
    it "duplicate" do
      expect(master_promotion.duplicate.parent_id).to eq(master_promotion.id)
      expect(master_promotion.duplicate.actions.size).to eq(master_promotion.actions.size)
      expect(master_promotion.duplicate.rules.size).to eq(master_promotion.rules.size)
      expect(master_promotion.duplicate.code).not_to eq(master_promotion.code)
    end

    it "is not active" do
      expect(Spree::Promotion.active).not_to include(master_promotion)
    end
  end
end
