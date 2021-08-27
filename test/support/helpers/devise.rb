# frozen_string_literal: true

module DeviseSystemTestHelpers
  def sign_in_as(email, password = nil)
    password ||= "password" unless Tarnhelm.active?(:user_magic_links)

    visit(new_user_session_url)
    assert_button("Send me a Magic Link")
    fill_in("Email", with: email)

    if password.present?
      click_to_show_password_fields if Tarnhelm.active?(:user_magic_links)
      fill_in("Password", with: password)
      click_on("Log in")
    else
      click_on("Send me a Magic Link")
      open_last_email
      click_first_link_in_email
    end

    assert_logged_in_ui
    User.find_by(email: email)
  end

  def sign_out
    find("#user-menu").click
    assert_link("Logout")
    click_on("Logout")
    assert_link("Login")
    assert_logged_out_ui
  end

  def sign_in_via_google(assertion: true)
    visit(new_user_registration_url)
    assert_button("Send me a Magic Link")

    VCR.use_cassette("omniauth_google") do
      click_on("Sign up with Google")
    end
    return unless assertion

    assert_flash(notice: "Successfully registered using your Google account.")
    AuthenticatingIdentity.find_with_omniauth(OmniAuth.config.mock_auth[:google]).user
  end

  def assert_user_can_switch_to_account(name: nil, show_flash: true)
    visit(root_url)
    find("#user-menu").click
    assert_link("Personal Account")
    click_on(name || "Personal Account")
    assert_equal(page.current_url, root_url)

    if show_flash
      message = name ? "Switched to #{name}'s account" : "Switched to your personal account."
      assert_flash(notice: message)
    else
      assert_no_flash
    end
  end

  def assert_linked_via_google
    visit(edit_user_registration_url)
    click_on("Social Logins")

    within(".oauth-google") do
      assert_selector("h3", text: "Google")
      assert_link("Remove")
    end

    assert_no_link("Link your Google account")
  end

  def click_to_show_password_fields(text = nil)
    if text
      find("span", text: text).click
    else
      find("span[data-devise--password-area-target='toggler']").click
    end
    assert_field("Password")
  end

  def assert_logged_in_ui(invert: [])
    assert_selector("h2", text: Tarnhelm.app.name)

    send(invert.include?("Login") ? :assert_link : :assert_no_link, "Login")
    send(invert.include?("Register") ? :assert_link : :assert_no_link, "Register")

    find("#user-menu").click
    send(invert.include?("Profile") ? :assert_no_link : :assert_link, "Edit Account")
    send(invert.include?("Logout") ? :assert_no_link : :assert_link, "Logout")
  end

  def assert_logged_out_ui(invert: [])
    assert_selector("h2", text: Tarnhelm.app.name)

    send(invert.include?("Login") ? :assert_no_link : :assert_link, "Login")
    send(invert.include?("Register") ? :assert_no_link : :assert_link, "Register")

    find("#user-menu").click if (["Profile", "Logout"] & invert).any?
    send(invert.include?("Profile") ? :assert_link : :assert_no_link, "Edit Account")
    send(invert.include?("Logout") ? :assert_link : :assert_no_link, "Logout")
  end
end
