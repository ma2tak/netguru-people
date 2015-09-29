require 'spec_helper'

describe UpdateUser do
  let(:user) { create(:user) }
  let(:current_user) { create(:user, :admin) }
  let(:params) do
    {
      'first_name' => 'John',
      'ability_ids' => ['']
    }
  end
  let(:send_mail_job) { SendMailJob.new }

  it 'updates user attributes' do
    expect do
      described_class.new(user, params, current_user).call
    end.to change { user.first_name }.from(user.first_name).to(params['first_name'])
  end

  context 'new ability' do
    it 'creates new abilities' do
      params['ability_ids'] << 'rails'

      expect do
        described_class.new(user, params, current_user).call
      end.to change { user.abilities.count }.from(0).to(1)
    end
  end

  context 'ability removed' do
    it 'removes existing ability from the user' do
      user.abilities << create(:ability)

      expect do
        described_class.new(user, params, current_user).call
      end.to change { user.abilities.count }.from(1).to(0)
    end
  end

  context 'notifications about changes send' do
    before do
      allow(SendMailJob).to receive(:new).and_return(send_mail_job)
      allow(send_mail_job).to receive(:async).and_return(send_mail_job)
    end

    it 'sends email if location changed' do
      expect(send_mail_job).to receive(:perform_with_user).with(
        UserMailer, :employment_or_location_changed, user, current_user).once

      described_class.new(user, { location_id: 99 }, current_user).call
    end

    it 'sends email if employment changed' do
      expect(send_mail_job).to receive(:perform_with_user).with(
        UserMailer, :employment_or_location_changed, user, current_user).once

      described_class.new(user, { employment: user.employment + 10 }, current_user).call
    end
  end

  context 'notifications about changes not send' do
    it "doesn't send an email if location or employment weren't updated" do
      expect(send_mail_job).to receive(:perform_with_user).with(
        UserMailer, :employment_or_location_changed, user, current_user).exactly(0).times

      described_class.new(user, params, current_user).call
    end
  end
end
