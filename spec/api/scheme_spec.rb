require "spec_helper"

RSpec.describe Api::Scheme do
  it "has a version number" do
    expect(Api::Scheme::VERSION).not_to be nil
  end

  xit "does something useful" do
    expect(false).to eq(true)
  end
end
