require 'active_support/core_ext/hash'
require 'active_support/core_ext/object/to_query'
require 'multi_json'
require 'oauth2'
require 'openssl'
require 'uri'
require 'cgi'
require 'time'
require 'base64'
require 'money'

module Mondo
  class Client
    include Utils::Hash

    DEFAULT_API_URL = "https://api.monzo.com"

    attr_accessor :access_token, :account_id, :api_url

    def initialize(parameters = {})
      symbolize_keys!(parameters)

      @access_token = parameters.fetch(:access_token)
      @account_id   = parameters.fetch(:account_id, nil)
      @api_url      = parameters.fetch(:api_url, DEFAULT_API_URL)

      require_access_token!

      set_account! unless @account_id
    end

    # Replies "pong"
    def ping
      api_request(:get, "/ping").parsed_response["ping"]
    end

    # Issue an GET request to the API server
    #
    # @note this method is for internal use
    # @param [String] path the path that will be added to the API prefix
    # @param [Hash] params query string parameters
    # @return [Hash] hash the parsed response data
    def api_get(path, params = {})
      api_request(:get, path, :params => params)
    end

    # Issue a POST request to the API server
    #
    # @note this method is for internal use
    # @param [String] path the path that will be added to the API prefix
    # @param [Hash] data a hash of data that will be sent as the request body
    # @return [Hash] hash the parsed response data
    def api_post(path, data = {})
      api_request(:post, path, :data => data)
    end

    # Issue a PUT request to the API server
    #
    # @note this method is for internal use
    # @param [String] path the path that will be added to the API prefix
    # @param [Hash] data a hash of data that will be sent as the request body
    # @return [Hash] hash the parsed response data
    def api_put(path, data = {})
      api_request(:put, path, :data => data)
    end

    # Issue a PATCH request to the API server
    #
    # @note this method is for internal use
    # @param [String] path the path that will be added to the API prefix
    # @param [Hash] data a hash of data that will be sent as the request body
    # @return [Hash] hash the parsed response data
    def api_patch(path, data = {})
      api_request(:patch, path, :data => data)
    end

    # Issue a DELETE request to the API server
    #
    # @note this method is for internal use
    # @param [String] path the path that will be added to the API prefix
    # @param [Hash] data a hash of data that will be sent as the request body
    # @return [Hash] hash the parsed response data
    def api_delete(path, data = {})
      api_request(:delete, path, :data => data)
    end

    # Issue a request to the API server, returning the full response
    #
    # @note this method is for internal use
    # @param [Symbol] method the HTTP method to use (e.g. +:get+, +:post+)
    # @param [String] path the path that will be added to the API prefix
    # @option [Hash] options additional request options (e.g. form data, params)
    def api_request(method, path, options = {})
      request(method, path, options)
    end

    # @method accounts
    # @return [Accounts] all accounts for this user
    def accounts(options = {})
      response = api_get("/accounts", options)

      with_parsed_response(response) do |parsed_response|
        parsed_response["accounts"].map do |account|
          Account.new(account, self)
        end
      end
    end

    # @method cards
    # @return [Cards] all cards for this user
    def cards(options = {})
      require_account_id!

      options.merge!(account_id: account_id)

      response = api_get("/card/list", options)

      with_parsed_response(response) do |parsed_response|
        parsed_response["cards"].map do |card|
          Card.new(card, self)
        end
      end
    end

    # @method transactions
    # @return [Transactions] all transactions for this user
    def transactions(options = {})
      require_account_id!

      options.merge!(account_id: account_id)

      response = api_get("/transactions", options)

      with_parsed_response(response) do |parsed_response|
        parsed_response["transactions"].map do |transaction|
          Transaction.new(transaction, self)
        end
      end
    end

    # @method transaction
    # @return <Transaction> of the transaction information
    def transaction(transaction_id, options = {})
      unless transaction_id
        raise ClientError.new("You must provide an transaction ID to query transactions")
      end

      response = api_get("/transactions/#{transaction_id}", options)

      with_parsed_response(response) do |parsed_response|
        Transaction.new(parsed_response["transaction"], self)
      end
    end

    # @method balance
    # @return <Balance> of the balance information
    def balance(for_account_id = nil)
      for_account_id ||= account_id

      require_account_id!

      response = api_get("balance", account_id: for_account_id)

      with_parsed_response(response) do |parsed_response|
        Balance.new(parsed_response, self)
      end
    end

    def create_feed_item(params)
      require_account_id!

      FeedItem.new(params, self).save
    end

    def register_web_hook(url)
      require_account_id!

      hook = WebHook.new({ account_id: account_id, url: url }, self)
      hook.save

      web_hooks << hook
    end

    def deregister_web_hook(webhook_id)
      require_account_id!

      response = api_delete("webhooks/#{webhook_id}")

      if [200, 204].include?(response.status)
        web_hooks.reject! { |webhook| webhook.id == webhook_id }
        web_hooks
      end
    end

    def web_hooks
      require_account_id!

      @web_hooks ||= begin
        response = api_get("webhooks", account_id: account_id)

        response.parsed_response["webhooks"].map do |webhook|
          WebHook.new(webhook, self)
        end
      end
    end

    def user_agent
      @user_agent ||= begin
        gem_info = "mondo-ruby/v#{Mondo::VERSION}"
        ruby_engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby"
        ruby_version = RUBY_VERSION
        ruby_version += " p#{RUBY_PATCHLEVEL}" if defined?(RUBY_PATCHLEVEL)
        comment = ["#{ruby_engine} #{ruby_version}"]
        comment << RUBY_PLATFORM if defined?(RUBY_PLATFORM)
        "#{gem_info} (#{comment.join("; ")})"
      end
    end

    # Send a request to the Mondo API servers
    #
    # @param [Symbol] method the HTTP method to use (e.g. +:get+, +:post+)
    # @param [String] path the path fragment of the URL
    # @option [Hash] options query string parameters, headers
    def request(method, path, options = {})
      raise ClientError, "Access token missing" unless @access_token

      options[:headers] = {} unless options[:headers]
      options[:headers]["Accept"] = "application/json"
      options[:headers]["Content-Type"] = "application/json" unless method == :get
      options[:headers]["User-Agent"] = user_agent
      options[:headers]["Authorization"] = "Bearer %s" % @access_token

      if options[:data].present?
        options[:body] = options[:data].to_param
        options[:headers]["Content-Type"] = "application/x-www-form-urlencoded" # sob sob
      end

      path = URI.encode(path)

      response = connection.run_request(method, path, options[:body], options[:headers]) do |req|
        req.params = options[:params] if options[:params].present?
      end

      response = Response.new(response)

      case response.status
      when 301, 302, 303, 307
        # TODO
      when 200..299, 300..399
        # on non-redirecting 3xx statuses, just return the response
        response
      when 400..599
        error = ApiError.new(response)
        raise(error, "Status code #{response.status}")
      else
        error = ApiError.new(response)
        raise(error, "Unhandled status code value of #{response.status}")
      end
    end

    def connection
      @connection ||= Faraday.new(api_url)
    end

    private

    def require_access_token!
      unless access_token
        raise ClientError.new("You must provide a valid access token")
      end
    end

    def require_account_id!
      unless account_id
        raise ClientError.new("You must provide an account ID to perform this action")
      end
    end

    def set_account!
      if account = accounts.first
        account_id = account.id
      end
    end

    def with_parsed_response(response)
      return response if response.error.present?

      yield response.parsed_response if block_given?
    end
  end
end
