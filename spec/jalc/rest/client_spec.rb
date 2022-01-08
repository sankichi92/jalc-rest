# frozen_string_literal: true

RSpec.describe JaLC::REST::Client do
  describe '#prefixes' do
    let(:client) { described_class.new }

    context 'without args' do
      before do
        stub_request(:get, 'https://api.japanlinkcenter.org/prefixes')
      end

      it 'requests "GET /prefixes"' do
        client.prefixes

        expect(WebMock).to have_requested(:get, 'https://api.japanlinkcenter.org/prefixes')
      end
    end

    context 'with args' do
      before do
        stub_request(:get, 'https://api.japanlinkcenter.org/prefixes').with(query: hash_including)
      end

      it 'requests "GET /prefixes" with params' do
        client.prefixes(ra: 'JaLC', sort: 'siteId', order: 'desc')

        expect(WebMock).to have_requested(:get, 'https://api.japanlinkcenter.org/prefixes')
                             .with(query: { ra: 'JaLC', sort: 'siteId', order: 'desc' })
      end
    end
  end
end
