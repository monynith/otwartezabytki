# encoding: utf-8
# == Schema Information
#
# Table name: alerts
#
#  id          :integer          not null, primary key
#  relic_id    :integer
#  user_id     :integer
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  file        :string(255)
#  state       :string(255)
#

class Alert < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :relic_id, :user_id, :file, :description
  attr_accessible :state, :as => :admin

  after_create :new_alert_notification

  validates :description, :presence => true

  scope :fixed, where("state = ?", "fixed")
  scope :not_fixed, where("state != ? or state is null", "fixed")

  mount_uploader :file, AlertUploader

  def state
    self[:state] || "new"
  end

  def new_alert_notification
    AlertMailer.notify_oz(self).deliver
  end
end
