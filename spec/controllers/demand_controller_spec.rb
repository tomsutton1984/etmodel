require 'spec_helper'

describe DemandController do
  render_views
  
  describe "GET intro" do
    it "should be successful" do
      get :intro
      response.should be_success
    end
  end
end