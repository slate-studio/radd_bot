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

  ## Class Methods
  def self.find_or_create_by_message(message)
    from       = message[:from]
    user_id    = from[:id]
    subscriber = Subscriber.where(user_id: user_id).first

    if not subscriber
      subscriber = Subscriber.create({
        user_id:    user_id,
        first_name: from[:first_name],
        last_name:  from[:last_name],
        username:   from[:username]
      })
    end

    subscriber
  end
end
