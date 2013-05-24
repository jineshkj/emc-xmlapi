
require 'logger'

$log          = Logger.new(STDOUT)
$log.level    = Logger::DEBUG
$log.progname = 'emc-xmlapi'

require 'emc/xmlapi/session'

module EMC
  module XMLAPI

    def self.start(host, user, options, &block)
      session = Session.new(host, user, options[:password])

      if session.login
        if block_given?
          ret = yield session
          session.logout
          ret
        else
          session
        end
      else
        raise "Authentication Error"
      end

    end # self.start

  end # XMLAPI
end # EMC