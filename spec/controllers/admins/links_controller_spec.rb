describe Admins::LinksController, type: :controller do

  describe "GET #index" do

    before { get :index }

    it { should respond_with(:success) }

    it { should render_template(:index) }

    it "loads all of the links into @links" do
      link1, link2 = Link.create!, Link.create!
      expect(assigns(:links)).to match_array([link1, link2])
    end
  end

  describe "GET #new" do

    context "with user" do
      login_user

      before { get :new }

      it { should respond_with(:success) }
      it { should render_template(:new) }
      it { expect(assigns(:link)).to be_a_new(Link) }

    end

    context "without user" do

      before { get :new }

      it { should redirect_to(new_user_session_path) }
    end
  end

  describe "POST #create" do

    context "with user" do
      login_user

      it "should have a current user" do
        expect(controller.current_user).to_not be_nil
      end

      context "with params" do
        before { post :create, link: attributes_for(:link) }

        it "creates the link" do
          expect(Link.count).to eq(1)
        end

        it { should redirect_to(admins_link_path(1)) }
      end

    end

    context "without user" do
      it "should not have a current user" do
        expect(controller.current_user).to be_nil
      end

      before { post :create, link: attributes_for(:link) }

      it { should redirect_to(new_user_session_path) }
    end

  end

  describe "PATCH #update" do
    context "with user" do
      login_user

      it "should have a current user" do
        expect(controller.current_user).to_not be_nil
      end

      let(:valid_update_attributes) do
        {
          title:    'updated_title',
          url:      'updated_url',
          user_id:  controller.current_user.id
        }
      end
      let(:link) { create(:link, user_id: controller.current_user.id) }

      before(:each) do
        patch :update, id: link.id, link: valid_update_attributes
        link.reload
      end

      it "updates link's attributes" do
        expect(link.title).to eq(valid_update_attributes[:title])
        expect(link.url).to eq(valid_update_attributes[:url])
      end

      it { should redirect_to(admins_link_path(link)) }
    end

    context "without user" do

      let(:valid_update_attributes) do
        {
          title:    'updated_title',
          url:      'updated_url',
        }
      end
      let(:link) { create(:link) }

      before(:each) do
        patch :update, id: link.id, link: valid_update_attributes
      end

      it { should redirect_to(new_user_session_path) }

    end

    context "not authorized" do
      login_user

      let(:valid_update_attributes) do
        {
          title:    'updated_title',
          url:      'updated_url',
          user_id:  3
        }
      end
      let(:link) { create(:link, user_id: 3) }

      before(:each) do
        patch :update, id: link.id, link: valid_update_attributes
        link.reload
      end

      it "doesnt updates link's attributes" do
        expect{link.title}.to_not change{valid_update_attributes[:title]}
        expect{link.url}.to_not change{valid_update_attributes[:url]}
      end

      it "notice not authorized" do
        expect(controller.notice).to eq('Not authorized to edit this link')
      end

      it { should redirect_to(admins_links_path) }
    end

  end

end
