require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::CloudAppsController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    # Stub model calls
    let(:admin) { build(:user, :admin) }
    let(:app) { build(:app, stack: 'cloud', uid: 'cld-1234', name: 'My App', api_key: '28034234') }

    before do
      api_stub_for(get: "/users/#{admin.id}", response: from_api(admin))
      api_stub_for(get: "/apps", response: from_api([app]))
      api_stub_for(get: "/apps/#{app.id}", response: from_api(app))
      api_stub_for(put: "/apps/#{app.id}", response: from_api(app))
    end

    context "admin user" do
      before do
        sign_in admin
      end

      describe "#index" do
        subject { get :index }
        
        it 'returns the cloud aplications' do
          subject
          expect(JSON.parse(response.body)).to eq({"cloud_apps"=>[{"id"=>app.id, "uid"=>app.uid, "name"=>app.name, "api_key"=>app.api_key}]})
        end
      end

      describe "#regenerate_api_key" do
        subject { put :regenerate_api_key, id: app.id }
        
        it 'regenerates the API key' do
          expect_any_instance_of(MnoEnterprise::App).to receive(:regenerate_api_key!)
          subject
        end
      end

      describe "#refresh_metadata" do
        subject { put :refresh_metadata, id: app.id }
        
        it 'refreshes the metadata' do
          expect_any_instance_of(MnoEnterprise::App).to receive(:refresh_metadata!)
          subject
        end
      end
    end
  end

end