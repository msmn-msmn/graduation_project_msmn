require 'rails_helper'

RSpec.describe "steps/show", type: :view do
  before(:each) do
    assign(:step, Step.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
