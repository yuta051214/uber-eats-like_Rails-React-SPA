class Order < ApplicationRecord
  has_many :line_foods

  validates :total_price, numericality: { greater_than: 0 }

  def save_with_update_line_foods!(line_foods)
    # トランザクション
    ActiveRecord::Base.transaction do
      # line_food の更新
      line_foods.each do |line_food|
        line_food.update_attributes!(active: false, order: self)
      end
      # order の保存
      self.save!
    end
  end
end
