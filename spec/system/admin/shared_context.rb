RSpec.shared_context "admin", shared_context: :metadata do
  before(:all) do
    Capybara.app_host = "http://admin.wifi.service.gov.uk"

    unless ENV["GW_USER"] && ENV["GW_PASS"] && ENV["GW_2FA_SECRET"]
      abort "\e[31mMust define GW_USER, GW_PASS, and GW_2FA_SECRET\e[0m"
    end

    login

    click_button("accept-cookies") if has_button?("accept-cookies")
  end

  after(:each) do |example|
    if example.exception
      warn("\e[35m#{page.body}\e[0m")
    end

    # persist the session
    Capybara.current_session.instance_variable_set(:@touched, false)
  end

  def login(password = ENV["GW_PASS"])
    visit "/"

    if page.current_path == "/users/sign_in"
      fill_in "user[email]", with: ENV["GW_USER"]
      fill_in "user[password]", with: password
      click_button "Continue"

      totp = ROTP::TOTP.new(ENV["GW_2FA_SECRET"])
      fill_in "code", with: totp.now
      click_button "Authenticate"
    end
  end

  def logout
    click_link "Sign out"
  end
end
