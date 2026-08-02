# frozen_string_literal: true

# Owner admin from Bowerbird identity (Railway env vars)
owner_email = ENV.fetch("BOWERBIRD_OWNER_EMAIL", "owner@example.com").downcase
owner_name  = ENV.fetch("BOWERBIRD_OWNER_NAME", "Owner")
owner_pass  = ENV.fetch("BOWERBIRD_OWNER_PASSWORD", "ChangeMeNow1!")

owner = User.find_or_initialize_by(email: owner_email)
owner.name = owner_name
if owner.new_record? || owner.encrypted_password.blank?
  owner.password = owner_pass
  owner.password_confirmation = owner_pass
end
owner.role = "admin"
owner.admin = true
owner.save!
puts "Seeded owner admin: #{owner.email}"
