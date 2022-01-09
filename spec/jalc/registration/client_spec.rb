# frozen_string_literal: true

RSpec.describe JaLC::Registration::Client do
  let(:client) { described_class.new(id: id, password: password) }
  let(:id) { 'sankichi92' }
  let(:password) { 'secret' }

  describe '#post' do
    context 'with XML result_method=0 (sync)' do
      let(:xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <root>
            <head>
              <result_method>0</result_method>
            </head>
          </root>
        XML
      end

      before do
        stub_request(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index').to_return(
          body: <<~XML,
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <root>
              <head>
                <totalcnt>1</totalcnt>
                <okcnt>1</okcnt>
                <ngcnt>0</ngcnt>
              </head>
              <body>
                <result>
                <seqno>000000000000001</seqno>
                <resultstatus>1</resultstatus>
                <doi>test001/test201</doi>
              </result>
              </body>
            </root>
          XML
        )
      end

      it 'posts XML and returns results (immediately)' do
        client.post(StringIO.new(xml))

        expect(WebMock).to have_requested(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index')
      end
    end

    context 'with XML result_method=2 (async)' do
      let(:xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <root>
            <head>
              <result_method>2</result_method>
            </head>
          </root>
        XML
      end

      before do
        stub_request(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index').to_return(
          body: <<~XML,
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <root>
              <head>
                <totalcnt>0</totalcnt>
                <okcnt>0</okcnt>
                <ngcnt>0</ngcnt>
                <exec_id>12345</exec_id>
              </head>
            </root>
          XML
        )
      end

      it 'posts XML and returns exec_id' do
        response = client.post(StringIO.new(xml))

        expect(response.body.root.get_text('head/exec_id')).to eq '12345'
        expect(WebMock).to have_requested(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index')
      end
    end

    context 'when returned XML has errcd=*' do
      before do
        stub_request(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index').to_return(
          body: <<~XML,
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <root>
              <head>
                <errcd>*</errcd>
              </head>
            </root>
          XML
        )
      end

      it 'raises AuthenticationError' do
        expect { client.post(StringIO.new('<?xml version="1.0" encoding="UTF-8"?><root />')) }
          .to raise_error JaLC::Registration::AuthenticationError
      end
    end

    context 'when returned XML has errcd=#' do
      before do
        stub_request(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index').to_return(
          body: <<~XML,
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <root>
              <head>
                <errcd>#</errcd>
              </head>
            </root>
          XML
        )
      end

      it 'raises InvalidXMLError' do
        expect { client.post(StringIO.new('<?xml version="1.0" encoding="UTF-8"?><root />')) }
          .to raise_error JaLC::Registration::InvalidXMLError
      end
    end

    context 'when returned XML has errcd=+' do
      before do
        stub_request(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index').to_return(
          body: <<~XML,
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <root>
              <head>
                <errcd>+</errcd>
              </head>
            </root>
          XML
        )
      end

      it 'raises RegistrationError' do
        expect { client.post(StringIO.new('<?xml version="1.0" encoding="UTF-8"?><root />')) }
          .to raise_error JaLC::Registration::RegistrationError
      end
    end
  end

  describe '#get_result' do
    before do
      stub_request(:get, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataResult/index')
        .with(query: hash_including(:login_id, :login_password, :exec_id))
        .to_return(
          body: <<~XML,
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <root>
              <head>
                <status>1</status>
              </head>
            </root>
          XML
        )
    end

    it 'fetches and returns the results' do
      response = client.get_result(12345)

      expect(response.body.root.get_text('head/status')).to eq 1
      expect(WebMock).to have_requested(:get, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataResult/index')
        .with(query: { login_id: id, login_password: password, exec_id: 12345 })
    end
  end
end
