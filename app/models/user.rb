class User < ApplicationRecord
  has_many :spaces, dependent: :destroy
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self

  validates :provider, presence: true, if: :uid?
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: :provider?
end
