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

  describe "skip_tracking_if option" do
    let(:runner) { spy("runner") }

    let(:app) {
      Class.new(Roda) do
        plugin :tracky_dacks,
          handler_options: {tracking_id: "abc"},
          skip_tracking_if: ->(request) { !request.env["HTTP_X_SPECIAL_HEADER"].nil? }

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

    it "does not track requests matching the skip_tracking_if option" do
      env = {
        "REQUEST_METHOD" => "GET",
        "PATH_INFO" => "/social",
        "QUERY_STRING" => "target=/test",
        "HTTP_X_SPECIAL_HEADER" => "SKIP-TRACKING",
        "SCRIPT_NAME" => "",
        "rack.input" => StringIO.new
      }
      response = rack_app.(env)

      expect(response[0]).to eq 302
      expect(response[1]).to eq({"Location"=>"/test", "Content-Type"=>"text/html", "Content-Length"=>"0"})
      expect(runner).not_to have_received(:call)
    end

    it "tracks requests not matching the skip_tracking_if option" do
      env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/social", "QUERY_STRING" => "target=/test", "SCRIPT_NAME" => "", "rack.input" => StringIO.new}
      response = rack_app.(env)

      expect(response[0]).to eq 302
      expect(response[1]).to eq({"Location"=>"/test", "Content-Type"=>"text/html", "Content-Length"=>"0"})
      expect(runner).to have_received(:call)
    end
  end
end
