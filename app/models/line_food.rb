class LineFood < ApplicationRecord
  belongs_to :food
  belongs_to :restaurant
  # optional: true は、外部キーのnilを許可する(関連付けを任意にする)
  belongs_to :order, optional: true

  validates :count, numericality: { greater_than: 0 }

  # 下記のscopeを設定することにより、LineFood.active とすることで、全てのLineFoodからwhereでactive: trueなものの一覧をActiveRecord_Relationオブジェクトとして返す。
  scope :active, -> { where(active: true ) }
  # restaurant_id が特定の店舗IDでないものの一覧を返す。他店舗のLineFoodの有無の確認に用いる。
  scope :other_restaurant, -> (picked_restaurant_id) { where.not(restaurant_id: picked_restaurant_id) }

  def total_amount
    # self.food.price * self.count
    food.price * count
  end
end
