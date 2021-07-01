require 'tmpdir'
require 'fileutils'

module Helpers
  class Capistrano
    def self.version_2?
      ENV['CAP_2_TEST'] == 'true'
    end

    def self.deploy_command
      return 'bundle exec cap deploy' if version_2?

      'bundle exec cap test deploy'
    end

    def self.example_path
      fixture_path = version_2? ? '../../examples/capistrano2' : '../../examples/capistrano3'

      File.join(File.dirname(__FILE__), fixture_path)
    end
  end
end
