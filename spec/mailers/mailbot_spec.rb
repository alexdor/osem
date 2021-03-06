require 'spec_helper'

describe Mailbot do
  let(:conference) { create(:conference) }
  let!(:email_settings) { create(:email_settings, conference: conference) }
  let(:user) { create(:user, email: 'user@example.com') }

  before { conference.contact.update_attributes(email: 'conf@domain.com') }

  context 'onboarding and proposal' do
    let(:event_user) { create(:submitter, user: user) }
    let(:event) { create(:event, program: conference.program, event_users: [event_user]) }

    shared_examples 'mailer actions' do
      it 'assigns the email subject' do
        expect(mail.subject).to eq 'Lorem Ipsum Dolsum'
      end

      it 'assigns the email receiver, sender, reply_to' do
        expect(mail.to).to eq ['user@example.com']
        expect(mail.from).to eq ['conf@domain.com']
        expect(mail.reply_to).to eq ['conf@domain.com']
      end

      it 'assigns the email body' do
        expect(mail.body).to eq 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit'
      end
    end

    describe '.registration_mail' do
      include_examples 'mailer actions' do
        let(:mail) { Mailbot.registration_mail conference, user }
      end
    end

    describe '.acceptance_mail' do
      before do
        conference.email_settings.update_attributes(send_on_accepted: true,
                                                    accepted_subject: 'Lorem Ipsum Dolsum',
                                                    accepted_body: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit')
      end

      include_examples 'mailer actions' do
        let(:mail) { Mailbot.acceptance_mail event }
      end
    end

    describe '.rejection_mail' do
      before do
        conference.email_settings.update_attributes(send_on_rejected: true,
                                                    rejected_subject: 'Lorem Ipsum Dolsum',
                                                    rejected_body: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit')
      end

      include_examples 'mailer actions' do
        let(:mail) { Mailbot.rejection_mail event }
      end
    end

    describe '.confirm_reminder_mail' do
      before do
        conference.email_settings.update_attributes(send_on_confirmed_without_registration: true,
                                                    confirmed_without_registration_subject: 'Lorem Ipsum Dolsum',
                                                    confirmed_without_registration_body: 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit')
      end

      include_examples 'mailer actions' do
        let(:mail) { Mailbot.confirm_reminder_mail event }
      end
    end

    describe '.build_email' do
      include_examples 'mailer actions' do
        let(:mail) { Mailbot.build_email conference, 'user@example.com', 'Lorem Ipsum Dolsum', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit' }
      end
    end
  end

  context 'update notifications' do
    it 'is a pending test'
  end
end
