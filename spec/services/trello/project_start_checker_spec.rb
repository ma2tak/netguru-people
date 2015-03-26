require 'spec_helper'

describe Trello::ProjectStartChecker do
  subject { Trello::ProjectStartChecker.new }

  let(:board) { AppConfig.trello.schedule_board_id }
  let(:key) { AppConfig.trello.developer_public_key }
  let(:token) { AppConfig.trello.member_token }
  let(:user) { create(:user, first_name: 'John', last_name: 'Doe') }

  before do
    stub_request(
      :get,
      "https://api.trello.com/1/boards/#{board}?key=#{key}&token=#{token}"
    ).to_return(
      status: 200,
      body: File.open(Rails.root.join('spec', 'fixtures', 'trello', 'board.json')),
      headers: {}
    )

    stub_request(
      :get,
      "https://api.trello.com/1/boards/5512a4c856f2ded676f66138/cards?filter=open&key=#{key}&token=#{token}"
    ).to_return(
      status: 200,
      body: File.open(Rails.root.join('spec', 'fixtures', 'trello', 'cards.json')),
      headers: {}
    )
  end

  context 'user card has a new label' do
    it 'creates a new membership for the user' do
      expect do
        subject.run!
      end.to change{user.memberships.count}.by 1
    end
  end
end
