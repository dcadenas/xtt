require File.dirname(__FILE__) + '/../spec_helper'
include StatusesHelper

def create_user name
  User.create! :login => name, :email => "#{name}@example.com", :password => "pass", :password_confirmation => "pass"
end

def a_time
  @a_time ||= Date.new(2001,1,1).to_time
end

def week_labels
  @week_labels ||= ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
end

describe ProjectsHelper do
  {0.5 => 10, 1 => 10, 3 => 10, 10.5 => 20, 15 => 20}.each do |max, normalized|
    it "#normalized_max([#{max}]).should == #{normalized}" do
      normalized_max([max]).should == normalized
    end
  end

  it "should show the correct legend for one user" do
    user_1 = create_user "user1"
    hours = [[user_1.id, a_time, 1.0]]

    days, chart_data, total, legend = fudge_data_from(hours, week_labels, :weekly )

    legend.should == "user1"
  end

  it "should show the correct legends for many users" do
    user_1 = create_user "user1"
    user_2 = create_user "user2"
    hours = [ [[user_1.id, a_time, 1.0]], [[user_2.id, a_time, 0.5]] ]

    days, chart_data, total, legend = fudge_data_from(hours, week_labels, :weekly )

    legend.should == "user1|user2"
  end
end

