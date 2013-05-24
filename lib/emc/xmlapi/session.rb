
require 'net/http'

module EMC
  module XMLAPI
    URL_LOGIN = '/Login'
    URL_MGMT  = '/servlets/CelerraManagementServices'

    class Session
      attr_reader :host, :user

      def initialize(host, username, password)
        @host      = host
        @user      = username
        @pass      = password
        @logged_in = false

        @http_conn = Net::HTTP.new(host, Net::HTTP.https_default_port)

        @http_conn.use_ssl     = true
        @http_conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      def logged_in?
        @logged_in
      end

      def login
        $log.debug { "Logging in to #{@host} as user #{@user}" }

        logout if @logged_in

        # TODO: need to check @user and @pass for invalid chars
        response = @http_conn.post(URL_LOGIN,
            "user=#{@user}&password=#{@pass}&Login=Login",
            'Content-Type' => 'application/x-www-form-urlencoded')

        if response.code_type == Net::HTTPOK
          @logged_in = true
          @cookie    = response['set-cookie'].split(';')[0]
        else
          @logged_in = false
        end

        $log.info { "Login #{@logged_in?'succeeded':'failed'} to #{@host}" }

        @logged_in
      end

      def execute(request)
        $log.debug "Execute request place holder."

        # TODO:
        #   * Create new HTTP POST request with body as request XML
        #   * Set Content-Type HTTP header to text/xml
        #   * POST to URL_MGMT
        #   * Check the HTTP response code is 200 OK. Otherwise return nil.
        #   * Obtain the body and build the XmlApiResponse object
        #   * Return the response object
      end

      def logout
        return if not @logged_in

        $log.debug { "Logging out of #{@host}" }

        # We need to perform a logout only if there has been a celerra session
        # open.
        if @celerra_session
          # TODO:
          #   * Create new HTTP POST request with 0 length body
          #   * Set Content-Type HTTP header to text/xml
          #   * Set CelerraConnector-Sess HTTP header
          #   * Set CelerraConnector-Ctl HTTP header with value as DISCONNECT
          #   * Perform POST to URL_MGMT
          #   * Check for HTTP 200 OK in response (can be ignored)
          response = @http_conn.post(URL_MGMT, '',
              'Content-Type'          => 'text/xml',
              'CelerraConnector-Sess' => @celerra_session,
              'CelerraConnector-Ctl'  => 'DISCONNECT')

          if response.code_type != Net::HTTPOK
            $log.warn { "Logout returned HTTP response #{response.code_type}" }
          end

          @celerra_session = nil
        end

        @logged_in = false
      end

    end
  end
end
