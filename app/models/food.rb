class Food < ApplicationRecord
  belongs_to :restaurant
  # optional: true は、外部キーのnilを許可する(関連付けを任意にする)
  belongs_to :order, optional: true
  has_one :line_food
end
