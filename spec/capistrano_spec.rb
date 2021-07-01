require_relative './spec_helper'

describe "bugsnag capistrano" do
  server = Helpers::Server.new

  before { server.start }
  after { server.stop }

  it "sends a deploy notification to the set endpoint" do
    ENV['BUGSNAG_ENDPOINT'] = server.url
    ENV['BUGSNAG_APP_VERSION'] = "1"

    Dir.chdir(Helpers::Capistrano.example_path) do
      system(Helpers::Capistrano.deploy_command)
    end

    payload = server.last_request
    expect(payload["apiKey"]).to eq('YOUR_API_KEY')
    expect(payload["appVersion"]).to eq("1")
    expect(payload["releaseStage"]).to eq('production')
  end

  it "allows modifications of deployment characteristics" do
    ENV['BUGSNAG_ENDPOINT'] = server.url
    ENV['BUGSNAG_API_KEY'] = "this is a test key"
    ENV['BUGSNAG_RELEASE_STAGE'] = "test"
    ENV['BUGSNAG_REVISION'] = "test"
    ENV['BUGSNAG_APP_VERSION'] = "1"
    ENV['BUGSNAG_REPOSITORY'] = "test@repo.com:test/test_repo.git"
    ENV['BUGSNAG_SOURCE_CONTROL_PROVIDER'] = "github"
    ENV['BUGSNAG_AUTO_ASSIGN_RELEASE'] = 'true'

    Dir.chdir(Helpers::Capistrano.example_path) do
      system(Helpers::Capistrano.deploy_command)
    end

    payload = server.last_request
    expect(payload["apiKey"]).to eq('this is a test key')
    expect(payload["releaseStage"]).to eq('test')
    expect(payload["appVersion"]).to eq("1")
    expect(payload["sourceControl"]).to_not be_nil
    expect(payload["sourceControl"]["revision"]).to eq("test")
    expect(payload["sourceControl"]["repository"]).to eq("test@repo.com:test/test_repo.git")
    expect(payload["sourceControl"]["provider"]).to eq("github")
    expect(payload["autoAssignRelease"]).to eq(true)
  end
end
