module Spree
  class SubscriptionsController < Spree::StoreController

    before_action :ensure_subscription
    before_action :ensure_subscription_belongs_to_user, only: :edit
    before_action :ensure_not_cancelled, only: [:update, :cancel, :pause, :unpause]

    def edit
    end

    def update
      if @subscription.update(subscription_attributes)
        respond_to do |format|
          format.html { redirect_to edit_subscription_path(@subscription), success: t('.success') }
          format.json { render json: { subscription: { price: @subscription.price, id: @subscription.id } }, status: 200 }
        end
      else
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: { errors: @subscription.errors.full_messages.to_sentence }, status: 422 }
        end
      end
    end

    def cancel
      result = Stripe::CancelSubscriptionService.new(@subscription).call

      if result[:success]
        respond_to do |format|
          format.json { render_success_json } 
          format.html { redirect_to_success }
        end
      else
        respond_with_error(result[:error], 422)
      end
    end
    
    def pause
      if @subscription.pause 
        redirect_to account_path, success: t(".success")
      else
        redirect_to account_path, error: t(".error")
      end
    end

    def unpause
      if @subscription.unpause
        redirect_to account_path, success: t(".success")
      else
        redirect_to account_path, error: t(".error")
      end
    end

    private

    def subscription_attributes
      params.require(:subscription).permit(:quantity, :next_occurrence_at, :delivery_number,
        :subscription_frequency_id, :variant_id, :prior_notification_days_gap,
        ship_address_attributes: [:firstname, :lastname, :address1, :address2, :city, :zipcode, :country_id, :state_id, :phone],
        bill_address_attributes: [:firstname, :lastname, :address1, :address2, :city, :zipcode, :country_id, :state_id, :phone])
    end

    def ensure_subscription
      @subscription = Spree::Subscription.active.find_by(id: params[:id])
      unless @subscription
        respond_to do |format|
          format.html { redirect_to account_path, error: Spree.t('subscriptions.alert.missing') }
          format.json { render json: { flash: Spree.t("subscriptions.alert.missing") }, status: 422 }
        end
      end
    end

    def ensure_not_cancelled
      if @subscription.not_changeable?
        respond_to do |format|
          format.html { redirect_back fallback_location: root_path, error: Spree.t("subscriptions.error.not_changeable") }
          format.json { render json: { flash: Spree.t("subscriptions.error.not_changeable") }, status: 422 }
        end
      end
    end

    def ensure_subscription_belongs_to_user
      authorize! :update, @subscription
    end
    
    def render_success_json
      render json: {
        subscription_id: @subscription.id,
        flash: t(".success"),
        method: Spree::Subscription::ACTION_REPRESENTATIONS[:cancel].upcase
      }, status: 200
    end
    
    def redirect_to_success
      redirect_to account_path, success: t(".success")
    end
    
    def respond_with_error(error_message, status)
      respond_to do |format|
        format.json { render json: { flash: error_message }, status: status }
        format.html { redirect_to account_path, flash: { error: error_message } }
      end
    end      
  end
end
