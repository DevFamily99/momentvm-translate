class Team < ApplicationRecord
  has_many :translations
  
  validates :id,  uniqueness: true
  validates :name,  presence: true
end
