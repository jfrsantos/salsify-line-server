require 'rails_helper'

describe LinesController, type: :controller do
  describe "GET #get" do
    let(:file_service) { double("FileService") }
    before do
      allow(FileService).to receive(:new).and_return(file_service)
      allow(file_service).to receive(:get_line_text).and_return("line text")
    end
    context "when the line number is within the file" do
      it "returns the line text" do
        get :get, params: { line_number: 1 }
        expect(response.body).to eq({"line" => "line text"}.to_json)
      end
    end
    context "when the line number is out of file" do
      before do
        allow(file_service).to receive(:get_line_text).and_raise(LoadError)
      end
      it "returns 'OUT OF FILE' message" do
        get :get, params: { line_number: 1 }
        expect(response.body).to eq({"error" => "OUT OF FILE"}.to_json)
      end
    end
  end
end
