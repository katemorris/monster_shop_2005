class BulkDiscount < ApplicationRecord
  validates_presence_of :name, :percent_off, :min_amount
  validates_numericality_of :percent_off, greater_than: 0
  validates_numericality_of :min_amount, greater_than: 0
  belongs_to :merchant
end
