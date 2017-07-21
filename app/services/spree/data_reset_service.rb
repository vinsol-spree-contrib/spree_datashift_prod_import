module Spree
  class DataResetService

    def reset_users(users = [])
      users = Spree.user_class.non_admins unless users.present?
      users.destroy_all
    end

    def reset_orders(orders = [])
      orders = Spree::Order.all unless orders.present?
      orders.destroy_all.map(&:number).join(', ')
    end

    def reset_users_with_orders(users = [])
      ActiveRecord::Base.transaction do
        users = Spree.user_class.non_admins unless users.present?
        Spree::Order.where(user_id: users.pluck(:id)).destroy_all
        users.destroy_all
        Spree.t(:users, scope: [:datashift_import, :reset_message])
      end
    rescue => e
      Spree.t(:exception_detail, scope: [:datashift_import, :reset_message], exception_detail: e.message)
    end

    def reset_products
      model_list = PRODUCT_DEPENDENT_MODELS
      ActiveRecord::Base.transaction do
        result_log = model_list.map do |model|
          klass = DataShift::SpreeEcom.get_spree_class(model)
          klass ? clear_model(klass) : Spree.t(:model_not_found, scope: :datashift_import, model: model)
        end
        result_log.join(', ')
      end
    rescue => e
      Spree.t(:exception_detail, scope: [:datashift_import, :reset_message], exception_detail: e.message)
    end

    private
      def clear_model(klass)
        klass.destroy_all
        Spree.t(:model_reset_successfully, scope: :datashift_import, model: klass.name.demodulize)
      end
  end
end
