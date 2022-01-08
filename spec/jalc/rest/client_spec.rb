# frozen_string_literal: true

RSpec.describe JaLC::REST::Client do
  describe '#prefixes' do
    before do
      stub_request(:get, 'https://api.japanlinkcenter.org/prefixes')
    end

    it 'executes a request to get DOI prefixes' do
      client = described_class.new

      client.prefixes

      expect(WebMock).to have_requested(:get, 'https://api.japanlinkcenter.org/prefixes')
    end
  end
end
