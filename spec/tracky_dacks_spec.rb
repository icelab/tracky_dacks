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
    env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/event", "QUERY_STRING" => "target=/test", "SCRIPT_NAME" => "", "rack.input" => StringIO.new}
    response = rack_app.(env)

    expect(response[0]).to eq 302
    expect(response[1]).to eq({"Location"=>"/test", "Content-Type"=>"text/html", "Content-Length"=>"0"})
    expect(runner).to have_received(:call)
  end

  context "with a truncated path and truncated params" do
    it "tracks requests passed to a Roda app by expanding truncated path and params" do
      env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/e", "QUERY_STRING" => "t=https%3A%2F%2Fwww.example.com%2Ftest&a=read&ti=Foobar&c=Podcasts", "SCRIPT_NAME" => "", "rack.input" => StringIO.new}
      response = rack_app.(env)

      expect(response[0]).to eq 302
      expect(response[1]).to eq({"Location"=>"https://www.example.com/test", "Content-Type"=>"text/html", "Content-Length"=>"0"})
      expect(runner).to have_received(:call).with(
        instance_of(TrackyDacks::Handlers::Event),
        hash_including(
          "action" => "read",
          "category" => "Podcasts",
          "target" => "https://www.example.com/test",
          "title" => "Foobar",
        )
      )
    end

    it "infers location and path from the target param if needed" do
      env = {"REQUEST_METHOD" => "GET", "PATH_INFO" => "/s", "QUERY_STRING" => "t=https%3A%2F%2Fwww.example.com%2Ftest", "SCRIPT_NAME" => "", "rack.input" => StringIO.new}
      response = rack_app.(env)

      expect(response[0]).to eq 302
      expect(response[1]).to eq({"Location"=>"https://www.example.com/test", "Content-Type"=>"text/html", "Content-Length"=>"0"})
      expect(runner).to have_received(:call).with(
        instance_of(TrackyDacks::Handlers::Social),
        hash_including(
          "location" => "https://www.example.com/test",
          "path" => "/test"
        )
      )
    end
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
