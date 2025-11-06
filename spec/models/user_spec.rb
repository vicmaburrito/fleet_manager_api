require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user@example.com').for(:email) }
    it { should allow_value('user.name+tag@example.co.uk').for(:email) }
    it { should_not allow_value('invalid').for(:email) }
    it { should_not allow_value('@example.com').for(:email) }
    it { should_not allow_value('user@').for(:email) }
  end

  describe 'password encryption' do
    it 'encrypts password using bcrypt' do
      user = create(:user, password: 'password123')

      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq('password123')
    end

    it 'authenticates with correct password' do
      user = create(:user, password: 'password123')

      expect(user.authenticate('password123')).to eq(user)
    end

    it 'fails authentication with incorrect password' do
      user = create(:user, password: 'password123')

      expect(user.authenticate('wrong')).to be_falsey
    end
  end
end
