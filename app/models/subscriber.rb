class Subscriber
  include Mongoid::Document
  include Mongoid::Timestamps

  ## Attributes
  field :user_id,    type: Integer
  field :username,   default: ''
  field :first_name, default: ''
  field :last_name,  default: ''

  ## Validations
  validates :user_id, presence: true

  ## Relations
  has_and_belongs_to_many :subscriptions, class_name: 'Feed', inverse_of: :subscribers, index: true

  ## Indexes
  index username: 1
  index user_id: 1
end
