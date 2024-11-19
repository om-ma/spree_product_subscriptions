module Spree
  class SubscriptionFrequency < Spree::Base
    has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency",
                                                dependent: :destroy
    has_many :subscriptions, class_name: "Spree::Subscription", dependent: :restrict_with_error

    validates :title, :months_count, presence: true
    validates :months_count, numericality: { greater_than: 0, only_integer: true, less_than_or_equal_to: 12 }, allow_blank: true

    def display_frequency
      "#{months_count} #{title}#{months_count == 1 ? "" : "s"}"
    end
  end
end
