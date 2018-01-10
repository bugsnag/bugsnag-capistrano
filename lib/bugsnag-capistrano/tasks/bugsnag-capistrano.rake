require "bugsnag-capistrano/deploy"

namespace :bugsnag do

  desc "Notify Bugsnag of a new deploy."
  task :deploy do
    api_key = ENV["BUGSNAG_API_KEY"]
    release_stage = ENV["BUGSNAG_RELEASE_STAGE"]
    app_version = ENV["BUGSNAG_APP_VERSION"]
    revision = ENV["BUGSNAG_REVISION"]
    repository = ENV["BUGSNAG_REPOSITORY"]
    provider = ENV["BUGSNAG_PROVIDER"]
    endpoint = ENV["BUGSNAG_ENDPOINT"]
    builder = ENV["BUGSNAG_BUILDER"]

    Rake::Task["load"].invoke unless api_key

    Bugsnag::Capistrano::Deploy.notify({
      :api_key => api_key,
      :release_stage => release_stage,
      :app_version => app_version,
      :revision => revision,
      :repository => repository,
      :provider => provider,
      :endpoint => endpoint,
      :builder => builder,
    })
  end

  namespace :heroku do
    desc "Add a heroku deploy hook to notify Bugsnag of deploys"
    task :add_deploy_hook => :load do
      # Wrapper to run command safely even in bundler
      run_command = lambda { |command|
        defined?(Bundler.with_clean_env) ? Bundler.with_clean_env { `#{command}` } : `#{command}`
      }

      # Fetch heroku config settings
      config_command = "heroku config --shell"
      config_command += " --app #{ENV["HEROKU_APP"]}" if ENV["HEROKU_APP"]
      heroku_env = run_command.call(config_command).split(/[\n\r]/).each_with_object({}) do |c, obj|
        k,v = c.split("=")
        obj[k] = (v.nil? || v.strip.empty?) ? nil : v
      end

      # Check for Bugsnag API key (required) using Bugsnag configuration only if available
      begin
        require 'bugsnag'
        api_key = heroku_env["BUGSNAG_API_KEY"] || Bugsnag.configuration.api_key || ENV["BUGSNAG_API_KEY"]
      rescue LoadError
        api_key = heroku_env["BUGSNAG_API_KEY"] || ENV["BUGSNAG_API_KEY"]
      end

      unless api_key
        puts "Error: No API key found, have you run 'heroku config:set BUGSNAG_API_KEY=your-api-key'?"
        next
      end

      # Build the request, making use of deploy hook variables
      # (https://devcenter.heroku.com/articles/deploy-hooks#customizing-messages)
      params = {
        :apiKey => api_key,
        :branch => "master",
        :revision => "{{head_long}}",
        :releaseStage => heroku_env["BUGSNAG_RELEASE_STAGE"] || heroku_env["RAILS_ENV"] || ENV["RAILS_ENV"] || "production",
        :provider => heroku_env["BUGSNAG_PROVIDER"],
        :builder => heroku_env["BUGSNAG_BUILDER"] || %x(whoami)
      }
      repo = `git config --get remote.origin.url`.strip
      params[:repository] = repo unless repo.empty?

      # Add the hook
      url = "https://build.bugsnag.com?" + params.map {|k,v| "#{k}=#{v}"}.join("&")
      command = "heroku addons:add deployhooks:http --url=\"#{url}\""
      command += " --app #{ENV["HEROKU_APP"]}" if ENV["HEROKU_APP"]

      puts "$ #{command}"
      run_command.call(command)
    end
  end

end

task :load do
  begin
    Rake::Task["environment"].invoke
  rescue
  end
end
