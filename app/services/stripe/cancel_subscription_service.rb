module Stripe
  class CancelSubscriptionService
    def initialize(subscription)
      @subscription = subscription
    end

    def call
      ActiveRecord::Base.transaction do
        @subscription.cancel_local_subscription && @subscription.cancel_stripe_subscription
        { success: true }
      rescue => e
        Rails.logger.error("Cancellation failed: #{e.message}")
        Raven.capture_exception(e)
        { success: false, error: e.message }
      end
    end
  end
end
