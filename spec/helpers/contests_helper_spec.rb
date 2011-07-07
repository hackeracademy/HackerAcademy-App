require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ContestsHelper. For example:
#
# describe ContestsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ContestsHelper do
  describe "duration_between method" do
    it "should give the difference between two DateTimes" do
      now = DateTime.now
      helper.duration_between(now, now + 3.hours).should ==
        "0 days, 3 hours, 0 minutes, 0 seconds"
    end
  end
end
