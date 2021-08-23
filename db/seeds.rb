def create_user(id)
	email = "#{id}@#{Tarnhelm.app.host}"
	password = Tarnhelm.hash(email, length: 12)

	user = User.find_or_initialize_by(email: email)
	user.password = user.password_confirmation = password
	user.skip_confirmation!
	user.save

	puts "=> created user: #{email} / #{password}"
end

# create rollouts
Tarnhelm.activate_initial_features!
puts "=> activated initial feature set for Tarnhelm"

if Rails.env.development?
	create_user :demo
	create_user :demo_team_member
	create_user :test
end