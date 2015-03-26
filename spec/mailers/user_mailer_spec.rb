require 'spec_helper'

describe UserMailer do
  describe 'send_password_recovery_instructions' do
    let(:mail) { described_class.send_password_recovery_instructions }
    it 'renders the headers'
    it 'renders the body'
  end
end
