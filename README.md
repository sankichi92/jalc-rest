# jalc-ruby

Ruby client for [JaLC (Japan Link Center)](https://japanlinkcenter.org/top/) API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jalc'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jalc

## Usage

### JaLC REST API

See https://api.japanlinkcenter.org/api-docs/index.html for API detail.

```ruby
require 'jalc'

JaLC::REST.config.logger = MyLogger.new

# GET /prefixes
prefixes_res = JaLC::REST.prefixes(ra: 'JaLC', sort: 'siteId', order: 'desc')
prefix = prefixes_res.body['data']['items'].first['prefix'] #=> "10.123"

# GET /doilist/:prefix
doilist_res = JaLC::REST.doilist(prefix, rows: 100)
doi = doilist_res.body['data']['items'].last['dois']['doi'] #=> "10.123/abc"

# GET /dois/:doi
doi_res = JaLC::REST.doi(doi)
doi_res.body['data']
```

### JaLC Registration API

See https://japanlinkcenter.org/top/doc/JaLC_tech_interface_doc.pdf for API detail

```ruby
require 'jalc'

JaLC::Registration.configure do |config|
  config.id = 'sankichi92'
  config.password = ENV['JALC_PASSWORD']
  config.logger = nil
end

res = JaLC::Registration.post(File.open('/path/to/xml'))
# response.body is an instance of REXML::Document
res.body.root.elements['head/okcnt'].text #=> "1"

# With XML head/result_method=2 (Async)
async_res = JaLC::Registration.post(StringIO.new(<<~XML))
  <?xml version="1.0" encoding="UTF-8"?>
  <root>
    <head>
      <result_method>2</result_method>
    </head>
    <body>
      ...
    </body
  </root>
XML
exec_id = async_res.body.root.elements['head/exec_id'].text #=> "12345"

result_res = JaLC::Registration.get_result(exec_id)
result_res.body.root.elements['head/status'].text #=> "2"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sankichi92/jalc-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sankichi92/jalc-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the jalc-ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sankichi92/jalc-ruby/blob/main/CODE_OF_CONDUCT.md).
