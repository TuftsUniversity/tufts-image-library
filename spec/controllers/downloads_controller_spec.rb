require 'spec_helper'

describe DownloadsController do

  describe "downloading a pdf" do
    before do
      @pdf = TuftsPdf.new(title: 'test download', displays: ['dl'])
      @pdf.inner_object.pid = 'tufts:MISS.ISS.IPPI'
      @pdf.datastreams["Archival.pdf"].dsLocation = "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_pdf/MISS.ISS.IPPI.archival.pdf"
      @pdf.datastreams["Archival.pdf"].mimeType = "application/pdf"
      @pdf.save!
    end
    describe "when signed in" do
      before do
        sign_in FactoryGirl.create(:admin)
      end
      it "should have a filename" do
        get :show, id: @pdf.pid, datastream_id: "Archival.pdf"
        expect(response.headers['Content-Disposition']).to eq "inline; filename=\"MISS.ISS.IPPI.archival.pdf\""
        expect(response.headers['Content-Type']).to eq "application/pdf"
      end
    end
    it "should require sign-in" do
      get :show, id: @pdf.pid, datastream_id: "Archival.pdf"
      expect(response).to redirect_to new_user_session_path
    end
  end
end
