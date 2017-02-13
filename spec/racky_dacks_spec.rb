require "spec_helper"
require "racky_dacks/app"
require "racky_dacks/job"


RSpec.describe "RackyDacks" do
  let(:runner) { spy("runner") }

  it "works" do
    roda_app = RackyDacks::App
    roda_app.opts[:racky_dacks][:runner] = runner # Pass runner directly so we can test it gets called
    app = roda_app.app

    env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/social", "SCRIPT_NAME" => "", "rack.input" => StringIO.new}
    response = app.(env)

    expect(response.first).to eq 302
    expect(runner).to have_received(:call)
  end
end
