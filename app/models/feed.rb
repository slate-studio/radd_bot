class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  ## Attributes
  field :url

  ## Relations
  has_and_belongs_to_many :subscribers, class_name: 'Subscriber', inverse_of: :subscriptions, index: true

  ## Indexes
  index url: 1
end
