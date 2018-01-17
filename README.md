# Api::Scheme

Provides simple error handling and param processing scheme
to make API and other actions for Rail Action Controller

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-api-scheme'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-api-scheme

## Usage

Do:

```
require 'api/scheme'
```

before usage. Then add the similar the following scheme
into the rails action controller:

```
class UsersController < ApplicationController
  include Api::Scheme

  error_map %W(ActionController::ParameterMissing)  => 400,
            %W(ActiveRecord::RecordInvalid)         => 422..0,
            %W(ActiveRecord::RecordNotUnique)       => 422..1

  param_map({
    user: [
      :first_name,
      :last_name,
      :email
    ]
  })

  render_error_with :render_error

  def create
    @user = User.create(permitted_params)
  end

  def render_error text, minor, major
    render json: { text: text, code: minor }, status: major
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rails-api-scheme.
