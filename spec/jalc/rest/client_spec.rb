# frozen_string_literal: true

require 'logger'

RSpec.describe JaLC::REST::Client do
  describe '#prefixes' do
    let(:client) { described_class.new(logger: Logger.new(nil)) }

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

    context 'when the response status is 400' do
      before do
        stub_request(:get, 'https://api.japanlinkcenter.org/prefixes?ra=invalid')
          .to_return(
            status: 400,
            headers: {
              'Content-Type' => 'application/json',
            },
            body: {
              message: {
                errors: {
                  message: 'raの値が不正です。',
                },
              },
            }.to_json,
          )
      end

      it 'raises BadRequestError' do
        expect { client.prefixes(ra: 'invalid') }.to raise_error JaLC::REST::BadRequestError
      end
    end
  end
end
