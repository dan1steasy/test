require 'spec_helper'

describe Task do
  before(:each) do
    @valid_attributes = {
      :description => "value for description",
      :is_complete => false,
      :created_by => 1,
      :updated_by => 1,
      :completed_by => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Task.create!(@valid_attributes)
  end

  it "should require a description" do
    empty_desc_task = Task.new(@valid_attributes.merge(:description => ''))
    empty_desc_task.should_not be_valid
  end

  it "should not be complete when created with blank is_complete attribute" do
    new_task = Task.new(@valid_attributes.merge(:is_complete => nil))
    new_task.should_not be_complete
  end
end
