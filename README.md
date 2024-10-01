# Activemerchant-Payrix

An implementation of the ActiveMerchant Gateway API for processing payments via Payrix.

## Manual Installation

Build the gem using `rake`:

    $ rake build

Add the gem to your project via Bundler by adding the following to your Gemfile:

    $ gem 'activemerchant_payrix', git: "https://github.com/Printavo/activemerchant_payrix"

## Automated Installation

In the future, you might be able to download and install this gem directly from [rubygems.org](https://rubygems.org) via Bundler or Gem. Unfortunately that is not currently available, but instructions have been left for our future selves.

Install the gem and add it to the application's Gemfile by executing:

    $ bundle add activemerchant_payrix

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install activemerchant_payrix

## Usage

Payrix Gateway can be used as a drop in processor anywhere ActiveMerchant::Gateway payment processing is supported. For more information please visit https://github.com/activemerchant/active_merchant .

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are _theoretically_ welcome on GitHub at the home of this gem.
