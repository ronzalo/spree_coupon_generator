require 'spec_helper'

describe Spree::Promotion do
  let(:master_promotion) {create(:promotion_with_order_adjustment, is_master: true) }

  context 'as parent' do
    context 'automatic load' do
      it "duplicate with generated code" do
        expect(master_promotion.duplicate.parent_id).to eq(master_promotion.id)
        expect(master_promotion.duplicate.actions.size).to eq(master_promotion.actions.size)
        expect(master_promotion.duplicate.rules.size).to eq(master_promotion.rules.size)
        expect(master_promotion.duplicate.code).not_to eq(master_promotion.code)
      end
    end

    context 'manual load' do
      it "duplicate with passed code" do
        expect(master_promotion.duplicate("custom_code").code).to eq("custom_code")
      end
    end

    context 'when parent is changed, update children too' do
      it 'add action to master promotion' do
        child = master_promotion.duplicate
        calculator = Spree::Calculator::FlatRate.new
        calculator.preferred_amount = 5
        action = Spree::Promotion::Actions::CreateAdjustment.create!(calculator: calculator)
        master_promotion.promotion_actions << action
        expect(child.promotion_actions.size).to eq(master_promotion.promotion_actions.size)
      end

      it 'add rule to master promotion' do
        child = master_promotion.duplicate
        master_promotion.promotion_rules << Spree::Promotion::Rules::FirstOrder.new
        expect(child.promotion_rules.size).to eq(master_promotion.promotion_rules.size)
      end

      it 'change attributes on master promotion' do
        child = master_promotion.duplicate
        master_promotion.name = "Other name"
        master_promotion.save

        expect(child.name).to eq("Other name")
      end
    end

    it "is not active" do
      expect(Spree::Promotion.active).not_to include(master_promotion)
    end
  end
end
