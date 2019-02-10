module Oxidized
  require 'open3'
  require_relative 'cli'

  class Dnsdig2 < Input
    include Input::CLI

    # TFTP utilizes UDP, there is not a connection. We simply specify an IP and send/receive data.
    def connect node
      @node = node
      Oxidized.logger.debug "DNSDIG: #{@node.name}"
      @log = File.open(Oxidized::Config::Log + "/#{@node.name}-dnsdig", 'w') if Oxidized.config.input.debug?
    end

    def cmd _zone
      nsserver = @node.auth[:username]
      cmdline = "/bin/dig +noall +answer @" + nsserver + " " + @node.name + " -t AXFR"
      Oxidized.logger.debug "DNSDIG: cmdline: #{cmdline}"
      config, _status = Open3.capture2(cmdline)
      @output = config
    end

    attr_reader :output

    private

    def disconnect
      @log.close if Oxidized.config.input.debug?
    end
  end
end
