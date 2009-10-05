require File.dirname(__FILE__) + '/../../spec_helper'


describe "ResourceFull::Render::XML" , :type => :controller do
  describe ResourceFullNamespacedMockRecordsController do
    describe "index" do
      it "renders all model objects using simple model_name when model_class is namespaced" do
        2.times { ResourceFullSpec::ResourceFullNamespacedMockRecord.create! }

        get :index, :format => 'xml'

        response.code.should == '200'
        response_hash = Hash.from_xml(response.body)['resource_full_namespaced_mock_records']
        response_hash.size.should == 2
      end
    end
    describe "show" do
      it "renders the model object" do
        record = ResourceFullSpec::ResourceFullNamespacedMockRecord.create!

        get :show, :id => record.id, :format => 'xml'

        response.code.should == '200'
        response.body.should have_tag("resource-full-namespaced-mock-record")
      end     
    end
    describe "new" do
      it "renders the XML for a new model object" do
        get :new, :format => 'xml'

        response.code.should == '200'
        response.body.should == ResourceFullSpec::ResourceFullNamespacedMockRecord.new.to_xml(:root => :resource_full_namespaced_mock_record)
      end
    end

    describe "create" do
      it "creates and renders a new model object with an empty body" do
        put :create, :resource_full_namespaced_mock_record => { 'name' => 'brian' }, :format => 'xml'

        response.code.should == '201'
        response.body.should == ResourceFullSpec::ResourceFullNamespacedMockRecord.find(:first).to_xml(:root => :resource_full_namespaced_mock_record)
        ResourceFullSpec::ResourceFullNamespacedMockRecord.find(:first).name.should == 'brian'
      end

      it "creates a new model object and returns a status code of 201 (created)" do
        put :create, :resource_full_namespaced_mock_record => { 'name' => 'brian' }, :format => 'xml'

        response.code.should == '201'
      end

      it "creates a new model object and places the location of the new object in the Location header" do
        put :create, :resource_full_namespaced_mock_record => {}, :format => 'xml'

        response.headers['Location'].should == resource_full_namespaced_mock_record_url(ResourceFullSpec::ResourceFullNamespacedMockRecord.find(:first))
      end
    end    

    describe "update" do
      it "updates and renders the model object" do
        record = ResourceFullSpec::ResourceFullNamespacedMockRecord.create!

        put :update, :id => record.id, :format => 'xml', :resource_full_namespaced_mock_record => {:name => 'the new name'}

        response.code.should == '200'
        response.body.should have_tag("resource-full-namespaced-mock-record") do
          with_tag "name", "the new name"
        end
      end
    end
  end

  describe ResourceFullNamespacedMockRecordWithXmlOverridesController do
    describe "index" do
      it "renders all model objects using simple model_name when model_class is namespaced" do
        2.times { ResourceFullSpec::ResourceFullNamespacedMockRecord.create! }

        get :index, :format => 'xml'

        response.code.should == '200'
        response_hash = Hash.from_xml(response.body)['my_index_roots']
        response_hash.size.should == 2
      end
    end
    describe "show" do
      it "renders the model object" do
        record = ResourceFullSpec::ResourceFullNamespacedMockRecord.create!

        get :show, :id => record.id, :format => 'xml'

        response.code.should == '200'
        response.body.should have_tag("my-show-root")
      end     
    end
    describe "new" do
      it "renders the XML for a new model object" do
        get :new, :format => 'xml'

        response.code.should == '200'
        response.body.should == ResourceFullSpec::ResourceFullNamespacedMockRecord.new.to_xml(:root => 'my_new_root')
      end
    end

    describe "create" do
      it "creates and renders a new model object with an empty body" do
        put :create, :resource_full_namespaced_mock_record => { 'name' => 'brian' }, :format => 'xml'

        response.code.should == '201'
        response.body.should == ResourceFullSpec::ResourceFullNamespacedMockRecord.find(:first).to_xml(:root => 'my_create_root')
        ResourceFullSpec::ResourceFullNamespacedMockRecord.find(:first).name.should == 'brian'
      end

      it "creates a new model object and returns a status code of 201 (created)" do
        put :create, :resource_full_namespaced_mock_record => { 'name' => 'brian' }, :format => 'xml'

        response.code.should == '201'
      end

      it "creates a new model object and places the location of the new object in the Location header" do
        put :create, :resource_full_namespaced_mock_record => {}, :format => 'xml'

        response.headers['Location'].should == resource_full_namespaced_mock_record_url(ResourceFullSpec::ResourceFullNamespacedMockRecord.find(:first))
      end
    end    

    describe "update" do
      it "updates and renders the model object" do
        record = ResourceFullSpec::ResourceFullNamespacedMockRecord.create!

        put :update, :id => record.id, :format => 'xml', :resource_full_namespaced_mock_record => {:name => 'the new name'}

        response.code.should == '200'
        response.body.should have_tag("my-update-root") do
          with_tag "name", "the new name"
        end
      end
    end
  end

  describe ResourceFullMockUsersController do

    class SomeNonsenseException < Exception; end

    before :each do
      controller.use_rails_error_handling!
      ResourceFullMockUser.delete_all
      ResourceFullMockUsersController.resource_identifier = :id
    end

    describe "index" do
      it "renders all model objects" do
        2.times { ResourceFullMockUser.create! }

        get :index, :format => 'xml'

        Hash.from_xml(response.body)['resource_full_mock_users'].size.should == 2
        response.code.should == '200'
      end

      it "renders all model objects using sub-class name" do
        2.times { ResourceFullMockSubUser.create! }

        get :index, :format => 'xml'
        Hash.from_xml(response.body)['resource_full_mock_sub_users'].size.should == 2
        response.code.should == '200'
      end

      it "rescues all unhandled exceptions with an XML response" do
        ResourceFullMockUser.expects(:find).raises SomeNonsenseException, "sparrow farts"

        get :index, :format => 'xml'

        response.code.should == '500'
        response.should have_tag("errors") { with_tag("error", "sparrow farts") }
      end

      it "it sends an exception notification email if ExceptionNotifier is enabled and still renders the XML error response" do
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

        get :index, :format => 'xml'

        response.code.should == '500'
        response.should have_tag("errors") { with_tag("error", "sparrow farts") }

        if cleanup
          Object.send :remove_const, :ExceptionNotifier
          Object.send :remove_const, :ExceptionNotifiable
        end
      end

      it "retains the generic error 500 when re-rendering unhandled exceptions" do
        ResourceFullMockUser.expects(:find).raises SomeNonsenseException, "sparrow farts"

        get :index, :format => 'xml'

        response.code.should == '500'
        response.should have_tag("errors") { with_tag("error", "sparrow farts") }
      end
    end

    describe "show" do
      it "renders the model object" do
        user = ResourceFullMockUser.create!

        get :show, :id => user.id, :format => 'xml'

        response.code.should == '200'
        response.body.should have_tag("resource-full-mock-user")
      end

      it "renders the appropriate error message if it can't find the model object" do
        get :show, :id => 1, :format => 'xml'

        response.code.should == '404'
        response.body.should have_tag("errors") { with_tag("error", "not found: 1") }
      end

      it "renders appropriate errors if a generic exception occurs" do
        mock_user = ResourceFullMockUser.create!
        ResourceFullMockUser.send :define_method, :to_xml do
          raise SomeNonsenseException, "sparrow farts"
        end

        begin
          get :show, :id => mock_user.id.to_s, :format => 'xml'

          response.code.should == '500'
          response.should have_tag("errors") { with_tag("error", "sparrow farts")}
        ensure
          ResourceFullMockUser.send :remove_method, :to_xml
        end
      end
    end

    describe "new" do
      it "renders the XML for a new model object" do
        get :new, :format => 'xml'

        response.code.should == '200'
        response.body.should == ResourceFullMockUser.new.to_xml
      end
    end

    describe "create" do
      it "creates and renders a new model object with an empty body" do
        put :create, :resource_full_mock_user => { 'first_name' => 'brian' }, :format => 'xml'

        response.code.should == '201'
        response.body.should == ResourceFullMockUser.find(:first).to_xml
        ResourceFullMockUser.find(:first).first_name.should == 'brian'
      end

      it "creates a new model object and returns a status code of 201 (created)" do
        put :create, :resource_full_mock_user => { 'first_name' => 'brian' }, :format => 'xml'

        response.code.should == '201'
      end

      it "creates a new model object and places the location of the new object in the Location header" do
        put :create, :resource_full_mock_user => {}, :format => 'xml'

        response.headers['Location'].should == resource_full_mock_user_url(ResourceFullMockUser.find(:first))
      end

      it "renders appropriate errors if a model validation fails" do
        ResourceFullMockUser.send :define_method, :validate do
          errors.add :first_name, "can't be blank" if self.first_name.blank?
        end

        begin
          put :create, :resource_full_mock_user => {}, :format => 'xml'

          response.code.should == '422'
          response.should have_tag("errors") { with_tag("error", "First name can't be blank")}
        ensure
          ResourceFullMockUser.send :remove_method, :validate
        end
      end

      it "renders appropriate errors if a generic exception is raised" do
        ResourceFullMockUser.send :define_method, :validate do
          raise SomeNonsenseException, "sparrow farts"
        end

        begin
          put :create, :resource_full_mock_user => {}, :format => 'xml'

          response.code.should == '500'
          response.should have_tag("errors") { with_tag("error", "sparrow farts")}
        ensure
          ResourceFullMockUser.send :remove_method, :validate
        end
      end
    end

    describe "edit" do
    end

    describe "update" do
      it "renders appropriate errors if a model could not be found" do
        put :update, :id => 1, :format => 'xml'

        response.code.should == '404'
        response.should have_tag("errors") { with_tag("error", "not found: 1")}
      end

      it "renders appropriate errors if a model validation fails" do
        mock_user = ResourceFullMockUser.create!
        ResourceFullMockUser.send :define_method, :validate do
          errors.add :first_name, "can't be blank" if self.first_name.blank?
        end

        begin
          put :update, :id => mock_user.id.to_s, :resource_full_mock_user => {:first_name => ''}, :format => 'xml'

          response.code.should == '422'
          response.should have_tag("errors") { with_tag("error", "First name can't be blank")}
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
          put :update, :id => mock_user.id.to_s, :format => 'xml'

          response.code.should == '500'
          response.should have_tag("errors") { with_tag("error", "sparrow farts") }
        ensure
          ResourceFullMockUser.send :remove_method, :validate
        end
      end
    end

    describe "destroy" do
      xit "renders appropriate errors if a model could not be found" do
        delete :destroy, :id => 1, :format => 'xml'

        response.code.should == '404'
        response.should have_tag("errors") { with_tag("error", "not found: 1")}
      end

      it "renders appropriate errors if a generic exception is raised" do
        mock_user = ResourceFullMockUser.create!
        ResourceFullMockUser.send :define_method, :destroy do
          errors.add_to_base("Cannot delete")
          raise ActiveRecord::RecordInvalid.new(self)
        end

        begin
          delete :destroy, :id => mock_user.id.to_s, :format => 'xml'

          response.code.should == '422'
          response.should have_tag("errors") { with_tag("error", "Validation failed: Cannot delete") }
        ensure
          ResourceFullMockUser.send :remove_method, :destroy
        end
      end
    end
  end
end