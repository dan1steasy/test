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
end
