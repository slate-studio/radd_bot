class SubscriberJob
  @queue = :subscribe_jobs

  def self.perform(params)
    ss = SubscriberService.new(params)
    ss.subscribe!
  end
end
