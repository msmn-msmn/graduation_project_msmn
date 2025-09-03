class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable


  has_many :tasks, dependent: :destroy
  has_many :sub_tasks, dependent: :destroy
  has_many :steps, dependent: :destroy

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }
  validates :daily_available_time, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true } # 正の整数であること
end
