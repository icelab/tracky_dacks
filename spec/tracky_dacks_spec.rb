require "spec_helper"
require "roda"

RSpec.describe "TrackyDacks" do
  let(:runner) { spy("runner") }

  let(:app) {
    Class.new(Roda) do
      plugin :tracky_dacks, handler_options: {tracking_id: "abc"}

      route do |r|
        r.tracky_dacks_routes
      end
    end
  }

  let(:rack_app) { app.app }

  before do
    # Pass a runner spy so we can verify calls
    app.opts[:tracky_dacks][:runner] = runner
  end

  it "tracks requests passed to a Roda app" do
    env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/social", "QUERY_STRING" => "target=/test", "SCRIPT_NAME" => "", "rack.input" => StringIO.new}
    response = rack_app.(env)

    expect(response[0]).to eq 302
    expect(response[1]).to eq({"Location"=>"/test", "Content-Type"=>"text/html", "Content-Length"=>"0"})
    expect(runner).to have_received(:call)
  end
end
