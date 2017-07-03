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

    def reset_products
      model_list = PRODUCT_DEPENDENT_MODELS
      result_log = model_list.map do |model|
        klass = DataShift::SpreeEcom.get_spree_class(model)
        klass ? clear_model(klass) : Spree.t(:model_not_found, scope: :datashift_import, model: model)
      end
      result_log.join(', ')
    end

    private
      def clear_model(klass)
        begin
          klass.destroy_all
          Spree.t(:model_reset_successfully, scope: :datashift_import, model: klass.name.demodulize)
        rescue => e
          Spree.t(:records_not_deleted, scope: :datashift_import, model: klass.name.demodulize, error: e.message)
        end
      end
  end
end
