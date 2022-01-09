# frozen_string_literal: true

RSpec.describe JaLC::Registration::Client do
  let(:client) { described_class.new(id: id, password: password) }
  let(:id) { 'sankichi92' }
  let(:password) { 'secret' }

  describe '#post' do
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

    it 'posts XML' do
      client.post(StringIO.new('<?xml version="1.0" encoding="UTF-8"?><root />'))

      expect(WebMock).to have_requested(:post, 'https://japanlinkcenter.org/jalc/infoRegistry/registDataReceive/index')
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
end
