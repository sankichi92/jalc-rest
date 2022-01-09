# frozen_string_literal: true

RSpec.describe JaLC::REST::Client do
  let(:client) { described_class.new }

  describe '#prefixes' do
    context 'without args' do
      before do
        stub_request(:get, 'https://api.japanlinkcenter.org/prefixes').to_return(
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            data: {
              items: [
                {
                  prefix: '10.123',
                  ra: 'JaLC',
                  siteId: 'sankichi92',
                  updated_date: '2022-1-09',
                }
              ],
            },
          }.to_json,
        )
      end

      it 'requests "GET /prefixes"' do
        response = client.prefixes

        expect(response.body['data']['items']).to be_an Array
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
        stub_request(:get, 'https://api.japanlinkcenter.org/prefixes?ra=invalid').to_return(
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

  describe '#doilist' do
    context 'without keyword args' do
      let(:prefix) { '10.123' }

      before do
        stub_request(:get, "https://api.japanlinkcenter.org/doilist/#{prefix}").to_return(
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            data: {
              items: [
                {
                  dois: {
                    doi: '10.123/abc',
                    url: 'http://example.com',
                  },
                  ra: 'JaLC',
                  siteId: 'sankichi92',
                  updated_date: '2022-01-09',
                }
              ],
            },
          }.to_json,
        )
      end

      it 'requests "GET /doilist/:prefix"' do
        response = client.doilist(prefix)

        expect(response.body['data']['items']).to be_an Array
        expect(WebMock).to have_requested(:get, "https://api.japanlinkcenter.org/doilist/#{prefix}")
      end
    end

    context 'with keyword args' do
      let(:prefix) { '10.123' }

      before do
        stub_request(:get, "https://api.japanlinkcenter.org/doilist/#{prefix}").with(query: hash_including)
      end

      it 'requests "GET /doilst/:prefix" with params' do
        client.doilist(
          prefix,
          from: '2021-01-01',
          to: '2021-12-31',
          rows: 100,
          page: 2,
          sort: 'updated_date',
          order: 'desc',
        )

        expect(WebMock).to have_requested(:get, "https://api.japanlinkcenter.org/doilist/#{prefix}")
          .with(
            query: {
              from: '2021-01-01',
              until: '2021-12-31',
              rows: 100,
              page: 2,
              sort: 'updated_date',
              order: 'desc',
            },
          )
      end
    end

    context 'when the response status is 404' do
      let(:prefix) { 'not_found' }

      before do
        stub_request(:get, "https://api.japanlinkcenter.org/doilist/#{prefix}").to_return(
          status: 404,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            message: {
              errors: {
                message: 'データが見つかりませんでした。',
              },
            },
          }.to_json,
        )
      end

      it 'raises ResourceNotFound' do
        expect { client.doilist(prefix) }.to raise_error JaLC::REST::ResourceNotFound
      end
    end
  end

  describe '#doi' do
    let(:doi) { '10.123/abc' }

    before do
      stub_request(:get, "https://api.japanlinkcenter.org/dois/#{doi}").to_return(
        headers: {
          'Content-Type' => 'application/json',
        },
        body: {
          data: {},
        }.to_json,
      )
    end

    it 'requests "GET /dois/:doi"' do
      response = client.doi(doi)

      expect(response.body['data']).to be_a Hash
      expect(WebMock).to have_requested(:get, "https://api.japanlinkcenter.org/dois/#{doi}")
    end
  end
end
