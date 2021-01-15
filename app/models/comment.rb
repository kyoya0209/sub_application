class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :micropost
  validates  :content, presence: true, length: { maximum: 140 }
  has_many   :notifications, dependent: :destroy
end
