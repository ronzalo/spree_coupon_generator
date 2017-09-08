require 'deep_cloneable'

Spree::Promotion.class_eval do
  belongs_to :parent, class_name: 'Spree::Promotion'
  has_many :children, class_name: 'Spree::Promotion', foreign_key: 'parent_id'
  scope :only_master, -> { where(parent_id: [false, nil]) }
  scope :not_master, -> { where(is_master: [false, nil]) }
  self.whitelisted_ransackable_attributes = ['code', 'path', 'promotion_category_id', 'parent_id', 'is_master']

  def self.active
    where('spree_promotions.starts_at IS NULL OR spree_promotions.starts_at < ?', Time.now).
      where('spree_promotions.expires_at IS NULL OR spree_promotions.expires_at > ?', Time.now).
      merge(Spree::Promotion.not_master)
  end

  def duplicate(code=nil)
    return unless is_master?
    code ||= random_code
    child = deep_clone(include: [:promotion_actions, :promotion_rules], skip_missing_associations: true)
    child.update_attributes(is_master: false, code: code)
    children << child
    child
  end

  private

  def random_code
    coupon = loop do
      random_token = SecureRandom.hex(4)
      break random_token unless self.class.exists?(code: random_token)
    end
  end
end
