Spree::UsersController.class_eval do

  before_action :load_subscriptions, only: :show

  private

    def load_subscriptions
      @orders = spree_current_user&.orders&.present? ? spree_current_user.orders.complete.order(completed_at: :desc) : []
      @subscriptions = @orders&.present? ? Spree::Subscription.active.order(created_at: :desc).with_parent_orders(@orders) : []
    end

end
