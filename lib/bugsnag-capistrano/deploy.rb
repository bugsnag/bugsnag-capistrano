require "json"
require "net/http"
require "logger"

module Bugsnag
  module Capistrano
    class Deploy

      HEADERS = {"Content-Type" => "application/json"}
      DEFAULT_DEPLOY_ENDPOINT = "https://build.bugsnag.com"
      BUILD_TOOL_NAME = "bugsnag-capistrano"

      def self.notify(opts = {})
        begin
          require 'bugsnag'
          self.notify_using_bugsnag(opts)
        rescue LoadError
          self.notify_without_bugsnag(opts)
        end
      end

      def self.notify_using_bugsnag(opts = {})

        configuration = Bugsnag.configuration.dup

        [:api_key, :app_version, :release_stage, :endpoint, :use_ssl,
        :proxy_host, :proxy_port, :proxy_user, :proxy_password].each do |param|
          unless opts[param].nil?
            configuration.send :"#{param}=", opts[param]
          end
        end

        if Gem::Version.new(Bugsnag::VERSION).release >= Gem::Version.new('6.0.0')
          endpoint = configuration.endpoint
        else
          endpoint = (configuration.use_ssl ? "https://" : "http://") + configuration.endpoint
        end

        sourceControl = {
          "revision" => opts[:revision],
          "repository" => opts[:repository],
          "provider" => opts[:provider]
        }.reject {|k,v| v == nil}

        parameters = {
          "apiKey" => configuration.api_key,
          "releaseStage" => configuration.release_stage,
          "appVersion" => configuration.app_version,
          "sourceControl" => sourceControl,
          "builderName" => opts[:builder] || %x(whoami),
          "buildTool" => BUILD_TOOL_NAME
        }.reject {|k,v| v == nil || v == {}}

        raise RuntimeError.new("No API key found when notifying of deploy") if !parameters["apiKey"] || parameters["apiKey"].empty?

        payload_string = ::JSON.dump(parameters)
        self.deliver(endpoint, payload_string)
      end

      def self.notify_without_bugsnag(opts = {})
        endpoint = (opts[:endpoint].nil? ? DEFAULT_DEPLOY_ENDPOINT : opts[:endpoint])

        sourceControl = {
          "revision" => opts[:revision],
          "repository" => opts[:repository],
          "provider" => opts[:provider]
        }.reject {|k,v| v == nil}

        parameters = {
          "apiKey" => opts[:api_key],
          "releaseStage" => opts[:release_stage],
          "appVersion" => opts[:app_version],
          "sourceControl" => sourceControl,
          "builderName" => opts[:builder] || %x(whoami),
          "buildTool" => BUILD_TOOL_NAME
        }.reject {|k, v| v == nil || v == {}}

        raise RuntimeError.new("No API key found when notifying of deploy") if !parameters["apiKey"] || parameters["apiKey"].empty?

        payload_string = ::JSON.dump(parameters)
        self.deliver(endpoint, payload_string)
      end

      def self.deliver(url, body)
        logger = Logger.new(STDOUT)
        logger.level = Logger::INFO
        begin
          request(url, body)
        rescue StandardError => e
          logger.warn("Notification to #{url} failed, #{e.inspect}")
          logger.warn(e.backtrace)
        end
      end

      def self.request(url, body)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.read_timeout = 15
        http.open_timeout = 15

        http.use_ssl = uri.scheme == "https"

        uri.path == "" ? "/" : uri.path
        request = Net::HTTP::Post.new(uri, HEADERS)
        request.body = body
        http.request(request)
      end
    end
  end
end
