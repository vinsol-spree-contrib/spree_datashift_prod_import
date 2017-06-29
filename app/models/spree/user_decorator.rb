Spree::User.class_eval do

  ### SCOPES ###
  scope :non_admins, -> { where.not(id: admin.pluck(:id)) }

end
