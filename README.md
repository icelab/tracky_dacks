# Tracky Dacks

Tracky Dacks provides non-intrusive, server-side Google Analytics tracking and redirects. It's implemented as a Roda plugin, which makes it easy to turn into a simple Rack mountable app.

Tracky Dacks accepts 3 different types of tracking events:

- Page views (`/pageview`)
- Social events (`/social`)
- Events (`/event`)

Each of these has its own endpoint. For each request, it will enqueue a background job (in-process, using [SuckerPunch](https://github.com/brandonhilkert/sucker_punch)) to record the event with Google Analytics, and then either redirect or return an empty image (if a `.png` extension is provided on the request path).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "tracky_dacks"
```

And then execute:

```sh
$ bundle
```

Or install it yourself:

```sh
$ gem install tracky_dacks
```

## Usage

To create a standalone tracker app, first create a Roda app, then enable the plugin (with your Google Analytics configuration) and its routes:

```ruby
class MyTracker < Roda
  plugin :tracky_dacks, handler_options: {tracking_id: "abc"}

  route do |r|
    r.tracky_dacks_routes
  end
end
```

You can then run this as a standalone rackup with a `config.ru` like the following:

```ruby
require "my_tracker" # path to the file with your app
run MyTracker.freeze.app
```

You can also mount this app within another Rack app, or even use the plugin directly from another Roda app.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To test SuckerPunch jobs, include:

```
 require 'sucker_punch/testing/inline'
```

It will run all `SuckerPunch` jobs inline rather than in separate threads, so you can `raise` errors etc.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome [on GitHub](https://github.com/icelab/tracky_dacks). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
