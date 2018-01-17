require "spec_helper"

RSpec.describe Rails::Api::Scheme do
  it "has a version number" do
    expect(Rails::Api::Scheme::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
