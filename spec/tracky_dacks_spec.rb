require "spec_helper"
require "roda"

RSpec.describe "TrackyDacks" do
  let(:runner) { spy("runner") }

  let(:app_class) {
    Class.new(Roda) do
      plugin :tracky_dacks, handler_options: {tracking_id: "abc"}

      route do |r|
        r.tracky_dacks_routes
      end
    end
  }

  it "tracks requests passed to a Roda app" do
    app_class.opts[:tracky_dacks][:runner] = runner # Pass runner directly so we can verify it gets called
    app = app_class.app

    env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/social", "SCRIPT_NAME" => "", "rack.input" => StringIO.new}
    response = app.(env)

    expect(response.first).to eq 302
    expect(runner).to have_received(:call)
  end
end
