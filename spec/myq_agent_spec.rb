require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::MyqAgent do
  before(:each) do
    @valid_options = Agents::MyqAgent.new.default_options
    @checker = Agents::MyqAgent.new(:name => "MyqAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  pending "add specs here"
end
