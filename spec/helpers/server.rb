require 'json'
require 'webrick'

module Helpers
  class Server
    def initialize
      @queue = Queue.new
      @server = nil
      @thread = nil
    end

    def start
      @server = WEBrick::HTTPServer.new({
        Port: 0,
        Logger: WEBrick::Log.new(STDOUT),
        AccessLog: []
      })

      @server.mount_proc('/deploy') do |req, res|
        @queue.push(req.body)

        res.status = 200
        res.body = "OK\n"
      end

      @thread = Thread.new { @server.start }

      loop do
        break if @server.status == :Running

        sleep(0.1)
      end
    end

    def stop
      @queue.clear
      @server.stop
      @thread.join(5)
      @server = nil
    end

    def url
      raise "Server is not running!" if @server.nil?

      "http://localhost:" + @server.config[:Port].to_s + "/deploy"
    end

    def last_request
      retries = 0

      begin
        JSON.parse(@queue.pop(true))
      rescue ThreadError
        raise if retries >= 10

        retries += 1
        sleep(0.1)

        retry
      end
    end
  end
end
