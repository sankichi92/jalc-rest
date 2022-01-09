# frozen_string_literal: true

RSpec.describe JaLC::Registration::Client do
  let(:client) { described_class.new(id: id, password: password) }
  let(:id) { 'sankichi92' }
  let(:password) { 'secret' }

  describe '#post' do
    before do
      stub_request(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index')
    end

    it 'posts XML' do
      client.post(StringIO.new(<<~XML))
        <?xml version="1.0" encoding="UTF-8"?>
        <root>
        </root>
      XML

      expect(WebMock).to have_requested(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index')
    end
  end
end
