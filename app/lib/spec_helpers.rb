module SpecHelpers

  def assign_devise_mapping
    before {
      @request.env["devise.mapping"] = Devise.mappings[:user]
    }
  end

  def sign_as *user_options

    let(:user){ FactoryGirl.create(:user, *user_options) }

    type = @metadata.fetch(:type)

    before do

      if type == :feature
        login_as(user, scope: :user)
      else
        sign_in(user, scope: :user)
      end

    end

  end
  
  def controller_ok status=200
    expect(response.status).to be status
    expect(response.body).to be_present
  end

  def page_ok status=200, feature=false
    expect(page.status_code).to be status unless feature
    expect(page.html).to be_present
  end
  
  def self.any_image
    Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'blank.jpg'))
  end

  def any_image
    SpecHelpers.any_image
  end
  
  def sop
    save_and_open_page
  end
  
  def assert_js_ok
    errors = evaluate_script("window.errors")
    expect(errors).to be_kind_of(Array)
    errors.reject!{|a, b, c|
      # a == "TypeError: e is undefined" # unrelated jQuery error
    }
    expect(errors).to eq []
    expect(errors.size).to be 0
  end
  
  def accept_dialog expected_text=false
    a = page.driver.browser.switch_to.alert
    expect(a.text).to eq expected_text if expected_text
    a.accept # or a.dismiss
  end
  
  def expect_unauthorized
    expect(subject).to receive(:user_not_authorized).once.with(any_args).and_call_original
    expect(subject).to rescue_from(Pundit::NotAuthorizedError).with :user_not_authorized
  end
  
  def expect_unauthenticated
    expect(controller).to redirect_to new_user_session_url
  end
  
  def any_day
    find('table.ui-datepicker-calendar tbody tr:nth-child(2) td:first-child').click
  end
  
  def next_month
    find('.ui-datepicker-next').click
  end
  
end