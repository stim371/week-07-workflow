require "rubygems"
require "bundler/setup"
require 'simplecov'
SimpleCov.start
require File.expand_path(File.dirname(__FILE__) + '/../lib/technology.rb')

describe "states" do

  subject { Technology.new } 

  context "when unapproved" do
    it "should start unapproved" do
      subject.unapproved?.should == true
      subject.current_state.to_s.should == "unapproved"
    end
    it "should not be publishable or retireable when unapproved" do
      subject.current_state.events.should_not have_key(:publish)
      subject.current_state.events.should_not have_key(:retire)
    end
    it "available events should be approve" do
      subject.current_state.events.should have_key(:approve)
      subject.current_state.events.keys.should == [:approve]
    end
  end

  context "when approved" do
    
    before :each do
      subject.approve!
    end
    
    it "should be approved" do
      subject.approved?.should == true
      subject.current_state.to_s.should == "approved"
    end
    it "should tell us it is approved" do
      expect { subject.approve!}.to_s == "technology is approved"
    end
    it "can be set back to unapproved" do
      subject.unapprove!
      subject.current_state.to_s.should == "unapproved"
    end
    it "available events should be publish and unapprove" do
      subject.current_state.events.should have_key(:publish)
      subject.current_state.events.should have_key(:unapprove)
      subject.current_state.events.keys.should == [:publish,:unapprove]
    end
    it "should not be retirable when approved" do
      expect { subject.retire! }.to raise_error
    end
  end

  context "when published" do
    
    before :each do
      subject.approve!
      subject.publish!
    end
    
    it "should be be published" do
      subject.published?.should == true
      subject.current_state.to_s.should == "published"
    end
    it "available events shold be retire" do
      subject.current_state.events.should have_key(:retire)
      subject.current_state.events.keys.should == [:retire]
    end
    it "should not have access to unapprove or approve events" do
      subject.current_state.events.should_not have_key(:unapprove)
      subject.current_state.events.should_not have_key(:approve)
    end
  end

  context "when retired" do
    
    before :each do
      subject.approve!
      subject.publish!
      subject.retire!
    end
    
    it "should be retired" do
      subject.retired?.should == true
      subject.current_state.to_s.should == "retired"
    end
    it "available events shold be hall of fame" do
      subject.current_state.events.keys.should == [:halloffame]
    end
    it "should not have access to unapprove, approve or publish events" do
      subject.current_state.events.should_not have_key(:unapprove)
      subject.current_state.events.should_not have_key(:approve)
      subject.current_state.events.should_not have_key(:publish)
    end
  end
  
  context "when hall of fame" do
    before :each do
      subject.approve!
      subject.publish!
      subject.retire!
      subject.halloffame!
    end
    
    it "should be in hall of fame" do
      subject.halloffame?.should == true
      subject.current_state.to_s.should == "halloffame"
    end
    it "available events should be empty" do
      subject.current_state.events.keys.should be_empty
    end
    it "should not have access to unapprove, approve, publish or retire events" do
      subject.current_state.events.should_not have_key(:unapprove)
      subject.current_state.events.should_not have_key(:approve)
      subject.current_state.events.should_not have_key(:publish)
      subject.current_state.events.should_not have_key(:retire)
    end
  end
end
