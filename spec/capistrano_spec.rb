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

  it "uses 'repo_url' in preference to 'BUGSNAG_REPOSITORY'" do
    ENV['BUGSNAG_REPOSITORY'] = "unused@repo.com:unused/unused_repo.git"

    capfile = Helpers::Capistrano.generate_capfile({
      bugsnag_api_key: "this is a test key",
      app_version: "1",
      bugsnag_auto_assign_release: true,
      bugsnag_builder: "bob",
      bugsnag_metadata: { a: 1, b: 2 },
      bugsnag_env: "test",
      current_revision: "test1234",
      repo_url: "test@repo.com:test/test_repo.git",
      bugsnag_source_control_provider: "github",
      bugsnag_endpoint: server.url,
    })

    Helpers::Capistrano.run(capfile)

    payload = server.last_request

    expect(payload["apiKey"]).to eq('this is a test key')
    expect(payload["appVersion"]).to eq("1")
    expect(payload["autoAssignRelease"]).to eq(true)
    expect(payload["builderName"]).to eq("bob")
    expect(payload["buildTool"]).to eq("bugsnag-capistrano")
    expect(payload["metadata"]).to eq({ "a" => 1, "b" => 2 })
    expect(payload["releaseStage"]).to eq("test")
    expect(payload["sourceControl"]).to eq({
      "revision" => "test1234",
      "repository" => "test@repo.com:test/test_repo.git",
      "provider" => "github",
    })
  end

  it "uses 'bugsnag_repo_url' in preference to 'repo_url'" do
    ENV['BUGSNAG_REPOSITORY'] = "unused@repo.com:unused/unused_repo.git"

    capfile = Helpers::Capistrano.generate_capfile({
      bugsnag_api_key: "this is a test key",
      app_version: "1",
      bugsnag_auto_assign_release: true,
      bugsnag_builder: "bob",
      bugsnag_metadata: { a: 1, b: 2 },
      bugsnag_env: "test",
      current_revision: "test1234",
      repo_url: "test@repo.com:test/test_repo.git",
      bugsnag_repo_url: "https://repo.com/test/test_repo.git",
      bugsnag_source_control_provider: "github",
      bugsnag_endpoint: server.url,
    })

    Helpers::Capistrano.run(capfile)

    payload = server.last_request

    expect(payload["apiKey"]).to eq('this is a test key')
    expect(payload["appVersion"]).to eq("1")
    expect(payload["autoAssignRelease"]).to eq(true)
    expect(payload["builderName"]).to eq("bob")
    expect(payload["buildTool"]).to eq("bugsnag-capistrano")
    expect(payload["metadata"]).to eq({ "a" => 1, "b" => 2 })
    expect(payload["releaseStage"]).to eq("test")
    expect(payload["sourceControl"]).to eq({
      "revision" => "test1234",
      "repository" => "https://repo.com/test/test_repo.git",
      "provider" => "github",
    })
  end
end
