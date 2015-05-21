describe Admins::LinksController, type: :controller do

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "loads all of the links into @links" do
      link1, link2 = Link.create!, Link.create!
      get :index
      expect(assigns(:links)).to match_array([link1, link2])
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

        it "redirects to current link" do
          expect(response).to redirect_to admins_link_path(1)
        end
      end

      context "without params" do
        it "creates the link" do
          create(:user) do |user|
            user.links.create!
          end

          expect(Link.count).to eq(1)
          expect(response).to be_success
        end
      end

    end

    context "without user" do
      it "should not have a current user" do
        expect(controller.current_user).to be_nil
      end

      it "redirects to sign_in page" do
        post :create, link: attributes_for(:link)

        expect(Link.count).to eq(0)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

  end

  describe "PUT #update" do
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

      it "redirects to current link" do
        expect(response).to redirect_to(admins_link_path(link.id))
      end
    end

    context "without user" do

      it "should not have a current user" do
        expect(controller.current_user).to be_nil
      end

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

      it "redirects to new user session path" do
        expect(response).to redirect_to(new_user_session_path)
      end
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

      it "renders template index" do
        expect(response).to redirect_to(admins_links_path)
      end
    end

  end

end
