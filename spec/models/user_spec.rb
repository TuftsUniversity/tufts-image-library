require 'rails_helper'

RSpec.describe User, :type => :model do

  it 'by default has the role of a registered user (after it is saved)' do
    user = FactoryGirl.build(:user)
    expect(user).to_not be_registered
    user.save
    expect(user).to be_registered
  end
end
