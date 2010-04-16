require File.dirname(__FILE__) + '/../../spec_helper'

describe "ResourceFull::Render::JSON", :type => :controller do
  controller_name "resource_full_mock_users"

  class SomeNonsenseException < Exception; end

  before :each do
    rescue_action_in_public!
    ResourceFullMockUser.delete_all
    ResourceFullMockUsersController.resource_identifier = :id
  end

  describe "index" do
    it "renders all model objects" do
      2.times { ResourceFullMockUser.create! }

      get :index, :format => 'json'

      hash = Hash.from_json(response.body)
      hash.size.should == 2
      response.code.should == '200'
    end

    it "rescues all unhandled exceptions with an JSON response" do
      ResourceFullMockUser.expects(:find).raises SomeNonsenseException, "sparrow farts"

      get :index, :format => 'json'

      response.code.should == '500'
      hash = Hash.from_json(response.body)
      hash["error"]["text"].should == "sparrow farts"
    end

    it "it sends an exception notification email if ExceptionNotifier is enabled and still renders the JSON error response" do
      cleanup = unless defined? ExceptionNotifier
        module ExceptionNotifier; end
        module ExceptionNotifiable; end
        true
      end

      ResourceFullMockUsersController.send :include, ExceptionNotifiable
      ResourceFullMockUser.expects(:find).raises SomeNonsenseException, "sparrow farts"
      ResourceFullMockUsersController.stubs(:exception_data).returns(nil)
      ResourceFullMockUsersController.any_instance.stubs(:consider_all_requests_local).returns(false)
      ResourceFullMockUsersController.any_instance.stubs(:local_request?).returns(false)
      ExceptionNotifier.expects(:deliver_exception_notification)

      get :index, :format => 'json'

      response.code.should == '500'
      hash = Hash.from_json(response.body)
      hash["error"]["text"].should == "sparrow farts"

      if cleanup
        Object.send :remove_const, :ExceptionNotifier
        Object.send :remove_const, :ExceptionNotifiable
      end
    end

    it "retains the generic error 500 when re-rendering unhandled exceptions" do
      ResourceFullMockUser.expects(:find).raises SomeNonsenseException, "sparrow farts"

      get :index, :format => 'json'

      response.code.should == '500'
      hash = Hash.from_json(response.body)
      hash["error"]["text"].should == "sparrow farts"
    end
  end

  describe "show" do
    it "renders the model object" do
      user = ResourceFullMockUser.create!

      get :show, :id => user.id, :format => 'json'

      response.code.should == '200'
      hash = Hash.from_json(response.body)
      hash.should have_key("resource_full_mock_user")
    end

    it "renders the appropriate error message if it can't find the model object" do
      get :show, :id => 1, :format => 'json'

      response.code.should == '404'
      hash = Hash.from_json(response.body)
      hash["error"]["text"].should == "Couldn't find ResourceFullMockUser with id=1"
    end

    it "renders appropriate errors if a generic exception occurs" do
      mock_user = ResourceFullMockUser.create!
      ResourceFullMockUser.send :define_method, :to_json do
        raise SomeNonsenseException, "sparrow farts"
      end

      begin
        get :show, :id => mock_user.id.to_s, :format => 'json'

        response.code.should == '500'
        hash = Hash.from_json(response.body)
        hash["error"]["text"].should == "sparrow farts"
      ensure
        ResourceFullMockUser.send :remove_method, :to_json
      end
    end
  end

  describe "new" do
    it "renders the JSON for a new model object" do
      get :new, :format => 'json'

      response.body.should == ResourceFullMockUser.new.to_json
    end
  end

  describe "create" do
    it "creates and renders a new model object with an empty body" do
      put :create, :resource_full_mock_user => { 'first_name' => 'brian' }, :format => 'json'

      response.body.should == ResourceFullMockUser.find(:first).to_json
      ResourceFullMockUser.find(:first).first_name.should == 'brian'
    end

    it "creates a new model object and returns a status code of 201 (created)" do
      put :create, :resource_full_mock_user => { 'first_name' => 'brian' }, :format => 'json'

      response.code.should == '201'
    end

    it "creates a new model object and places the location of the new object in the Location header" do
      put :create, :resource_full_mock_user => {}, :format => 'json'

      response.headers['Location'].should == resource_full_mock_user_url(ResourceFullMockUser.find(:first))
    end

    it "renders appropriate errors if a model validation fails" do
      ResourceFullMockUser.send :define_method, :validate do
        errors.add :first_name, "can't be blank" if self.first_name.blank?
      end

      begin
        put :create, :resource_full_mock_user => {}, :format => 'json'

        hash = Hash.from_json(response.body)
        hash["resource_full_mock_user"]["errors"]["full_messages"][0].should == "First name can't be blank"
      ensure
        ResourceFullMockUser.send :remove_method, :validate
      end
    end

    it "renders appropriate errors if a generic exception is raised" do
      ResourceFullMockUser.send :define_method, :validate do
        raise SomeNonsenseException, "sparrow farts"
      end

      begin
        put :create, :resource_full_mock_user => {}, :format => 'json'

        response.code.should == '500'
        hash = Hash.from_json(response.body)
        hash["error"]["text"].should == "sparrow farts"
      ensure
        ResourceFullMockUser.send :remove_method, :validate
      end
    end
  end

  describe "edit" do
  end

  describe "update" do
    it "renders appropriate errors if a model could not be found" do
      put :update, :id => 1, :format => 'json'

      response.code.should == '404'
      hash = Hash.from_json(response.body)
      hash["error"]["text"].should == "Couldn't find ResourceFullMockUser with id=1"
    end

    it "renders appropriate errors if a model validation fails" do
      mock_user = ResourceFullMockUser.create!
      ResourceFullMockUser.send :define_method, :validate do
        errors.add :first_name, "can't be blank" if self.first_name.blank?
      end

      begin
        put :update, :id => mock_user.id.to_s, :resource_full_mock_user => {:first_name => ''}, :format => 'json'

        response.code.should == '422'
        hash = Hash.from_json(response.body)
        hash["resource_full_mock_user"]["errors"]["full_messages"].should == ["First name can't be blank"]
      ensure
        ResourceFullMockUser.send :remove_method, :validate
      end
    end

    it "renders appropriate errors if a generic exception is raised" do
      mock_user = ResourceFullMockUser.create!
      ResourceFullMockUser.send :define_method, :validate do
        raise SomeNonsenseException, "sparrow farts"
      end

      begin
        put :update, :id => mock_user.id.to_s, :format => 'json'

        response.code.should == '500'
        hash = Hash.from_json(response.body)
        hash["error"]["text"].should == "sparrow farts"
      ensure
        ResourceFullMockUser.send :remove_method, :validate
      end
    end
  end

  describe "destroy" do
    it "renders appropriate errors if a model could not be found" do
      delete :destroy, :id => 1, :format => 'json'

      response.code.should == '404'
      hash = Hash.from_json(response.body)
      hash["error"]["text"].should == "Couldn't find ResourceFullMockUser with id=1"
    end

    it "renders appropriate errors if a generic exception is raised" do
      mock_user = ResourceFullMockUser.create!
      ResourceFullMockUser.send :define_method, :destroy do
        errors.add_to_base("Cannot delete")
        raise ActiveRecord::RecordInvalid.new(self)
      end

      begin
        delete :destroy, :id => mock_user.id.to_s, :format => 'json'

        response.code.should == '422'
        hash = Hash.from_json(response.body)
        hash["error"]["text"].should == "Validation failed: Cannot delete"
      ensure
        ResourceFullMockUser.send :remove_method, :destroy
      end
    end

    it "renders error if the model could not be destroyed"
  end

  if ([Rails::VERSION::MAJOR, Rails::VERSION::MINOR] <=> [2,1]) >= 0 # if the rails version is 2.1 or greater...
    it "renders the model object" do
      user = ResourceFullMockUser.create!

      get :show, :id => user.id, :format => 'json'

      user.to_json.should == response.body
      hash = Hash.from_json(response.body)
      hash["resource_full_mock_user"].should_not be_nil
      response.code.should == '200'
    end
  end
end
