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

    def self.generate_capfile(variables)
      return generate_v2_capfile(variables) if version_2?

      capfile = <<-RUBY.gsub(/^\s+/, "")
        require "capistrano/setup"

        require "capistrano/deploy"
        require "capistrano/scm/git"
        install_plugin Capistrano::SCM::Git

        require "bugsnag-capistrano"
      RUBY

      # add calls to set each variable - "set(:key, value)"
      variables.each do |key, value|
        capfile << "set(:#{key}, #{value.inspect})\n"
      end

      capfile
    end

    def self.generate_v2_capfile(variables)
      capfile = "require 'bugsnag-capistrano'\n"

      # add calls to set each variable - "set(:key, value)"
      variables.each do |key, value|
        capfile << "set(:#{key}, #{value.inspect})\n"
      end

      # add an empty deploy task
      capfile << "task :deploy do\nend"

      capfile
    end

    def self.run(capfile)
      Dir.mktmpdir do |path|
        FileUtils.cp_r("#{example_path}/.", path)

        File.open("#{path}/Capfile", "w") do |file|
          file.write(capfile)
        end

        Dir.chdir(path) do
          system(deploy_command)
        end
      end
    end
  end
end
