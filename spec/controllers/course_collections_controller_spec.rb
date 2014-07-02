require 'rails_helper'

describe CourseCollectionsController do
  let(:image) { FactoryGirl.create(:image) }
  let(:collection) { FactoryGirl.create(:course_collection, user: user) }

  describe "for an unauthenticated user" do
    describe "create" do
      it "redirects to sign in" do
        post 'create', course_collection: {title: 'foo'}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET 'show'" do
      it "redirects to sign in" do
        get :show, id: 'collection:1'
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "PATCH 'append_to'" do
      it "redirects to sign in" do
        patch 'append_to', id: 'collection:1', pid: 'pid:1'
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "for a non-admin user" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    describe "create" do
      it "denies access" do
        expect{
          post 'create', course_collection: {title: 'foo'}
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe "GET 'show'" do
      it "returns http success" do
        get :show, id: collection
        expect(response).to be_successful
        expect(assigns[:curated_collection]).to eq collection
        expect(response).to render_template(:show)
      end
    end

    describe "PATCH 'append_to'" do
      it "denies access" do
        expect{
          patch 'append_to', id: collection, pid: 'pid:1'
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "an admin user" do
    let(:user) { FactoryGirl.create(:admin) }
    before { sign_in user }

    describe "POST 'create'" do
      it "creates a course collection" do
        expect {
          post 'create', course_collection: {title: 'foo'}
        }.to change {CourseCollection.count }.by(1)

        expect(response.status).to eq 302
        expect(assigns[:curated_collection].read_groups).to eq ['public']
        expect(assigns[:curated_collection].edit_users).to eq [user.user_key]
        expect(assigns[:curated_collection].displays).to eq ['tdil']
      end

      context 'with a bad title' do
        it "displays the form to fix the title" do
          count = CourseCollection.count
          post 'create', course_collection: {title: nil}
          expect(CourseCollection.count).to eq count
          expect(response).to be_successful
          expect(response).to render_template(:new)
        end
      end

      it 'uses the next sequence for the pid' do
        pending
        Sequence.where(name: nil, value: 100).create
        n = Sequence.where(name: 'curated_collection').first_or_create.value
        # if multiple sequences have the same value, this test doesn't test anything
        expect(Sequence.pluck(:value).uniq).to be_truthy

        post 'create', course_collection: {title: 'foo'}
        expect(assigns[:curated_collection].pid).to eq "tufts:uc.#{n + 1}"
      end
    end

    describe "GET 'show'" do
      it "returns http success" do
        get :show, id: collection
        expect(response).to be_successful
        expect(assigns[:curated_collection]).to eq collection
        expect(response).to render_template(:show)
      end
    end

    describe "GET 'new'" do
      it "returns http success" do
        get :new
        expect(response).to render_template(:new)
        expect(assigns[:curated_collection]).to be_kind_of CourseCollection
        expect(response).to be_successful
      end
    end

    describe "GET 'edit'" do
      it "returns http success" do
        get :edit, id: collection
        expect(response).to render_template(:edit)
        expect(assigns[:curated_collection]).to eq collection
        expect(response).to be_successful
      end
    end

    describe "PATCH 'append_to'" do
      it "returns http success" do
        patch 'append_to', id: collection, pid: image.pid
        expect(response).to be_successful
        expect(collection.reload.members).to eq [image]
      end
    end
  end  # describe admin user

end
