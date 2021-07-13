require_relative './spec_helper'

require 'rspec/expectations'
require 'rspec/mocks'
require 'webmock/rspec'

require 'bugsnag-capistrano/release'

module Bugsnag::Capistrano
  class Release
    attr_accessor :logger
  end
end

describe Bugsnag::Capistrano::Release do
  it "should call notify_without bugsnag" do
    expect(Bugsnag::Capistrano::Release).to receive(:deliver)
    Bugsnag::Capistrano::Release.notify({:api_key => "test", :app_version => "1"})
  end

  it "delivers a request to the given url" do
    url = "http://localhost:56456"
    stub_request(:post, url)
      .to_return(status:200, body: "")
    Bugsnag::Capistrano::Release.deliver(url, nil)
  end

  it "delivers a body unmodified" do
    body = ::JSON.dump({
      "paramA" => 'a',
      "paramB" => 'b',
      "paramHash" => {
        "one" => 1,
        "two" => 2,
        "three" => 3
      }
    })
    url = "http://localhost:56456"
    request = stub_request(:post, url)
      .with(body: body, headers: { 'Content-Type' => 'application/json'})
      .to_return(status:200, body: "")
    Bugsnag::Capistrano::Release.deliver(url, body)
    assert_requested request
  end

  it "cannot send without an apikey" do
    expect(Bugsnag::Capistrano::Release).to_not receive(:deliver)
    expect(Bugsnag::Capistrano::Release.logger).to receive(:warn).with("Cannot deliver notification. Missing required apiKey")

    Bugsnag::Capistrano::Release.notify()
  end

  it "cannot send without an appVersion" do
    expect(Bugsnag::Capistrano::Release).to_not receive(:deliver)
    expect(Bugsnag::Capistrano::Release.logger).to receive(:warn).with("Cannot deliver notification. Missing required appVersion")

    Bugsnag::Capistrano::Release.notify({:api_key => "test"})
  end

  context "with bugsnag installed" do
    before do
      module Kernel
        alias_method :old_require, :require
        def require(path)
          old_require(path) unless /^bugsnag/.match(path)
        end
      end
    end

    it "gets information from bugsnag configuration if available" do
      config = double
      allow(config).to receive(:api_key).and_return("bugsnag_api_key")
      allow(config).to receive(:app_version).and_return("bugsnag_app_version")
      allow(config).to receive(:release_stage).and_return("bugsnag_release_stage")

      allow(Bugsnag).to receive(:configuration).and_return(config)
      expect(Bugsnag::Capistrano::Release).to receive(:deliver) do |uri, body_string|
        expect(uri).to eq(Bugsnag::Capistrano::Release::DEFAULT_BUILD_ENDPOINT)
        body = ::JSON.parse(body_string)
        expect(body["apiKey"]).to eq("bugsnag_api_key")
        expect(body["appVersion"]).to eq("bugsnag_app_version")
        expect(body["releaseStage"]).to eq("bugsnag_release_stage")
      end

      Bugsnag::Capistrano::Release.notify()
    end

    after do
      module Kernel
        alias_method :require, :old_require
      end
    end
  end
end
