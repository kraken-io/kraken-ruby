require 'active_support/ordered_options'
require 'forwardable'
require 'delegate'
require 'json'

module Kraken
  class Response < SimpleDelegator
    extend Forwardable

    def_delegators :@parsed, :success, :file_name, :original_size,
      :kraked_size, :saved_bytes, :kraked_url, :id, :message

    def initialize(response)
      super(response)
      @parsed = ActiveSupport::InheritableOptions.new(JSON.parse(response.body).with_indifferent_access)
    end

    alias_method :original_response, :__getobj__
  end
end
