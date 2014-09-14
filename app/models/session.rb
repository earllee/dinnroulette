class Session < ActiveRecord::Base
  validates :token, :order, presence: true
  before_validation :gen_token, on: :create

  def gen_token
    begin
      self.token = SecureRandom.urlsafe_base64()
    end while self.class.exists?(token: self.token)
  end
end
