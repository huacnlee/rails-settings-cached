require "spec_helper"

describe RailsSettings do
  describe "Implementation" do
    it "can simple use" do
      Setting.foo = "Foo"
      Setting.foo.should == "Foo"
    end
  end
end