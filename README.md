<a name="ledgersync" />

# LedgerSync

[![Build Status](https://travis-ci.org/LedgerSync/ledger_sync.svg?branch=master)](https://travis-ci.org/LedgerSync/ledger_sync)
[![Gem Version](https://badge.fury.io/rb/ledger_sync.svg)](https://badge.fury.io/rb/ledger_sync)
[![Coverage Status](https://coveralls.io/repos/github/LedgerSync/ledger_sync/badge.svg?branch=master)](https://coveralls.io/github/LedgerSync/ledger_sync?branch=master)

<a name="joinTheConversation" />

## Join the Conversation

[Click here](https://join.slack.com/t/ledger-sync/shared_invite/zt-e5nbl8qc-eOA~5k7bg3p16_l3J7OS~Q) to join our public Slack group.

**Table of Content**
- [LedgerSync](#ledgersync)	- [Join the Conversation](#joinTheConversation)	- [Documentation](#documentation)	- [License](#license)	- [Maintainers](#maintainers)- [Getting Started](#gettingStarted)	- [Installation](#installation)		- [Gemfile](#gemfile)		- [Directly](#directly)	- [Quick Start](#quickStart)		- [Overview](#overview)			- [Manually save values](#manuallySaveValues)		- [Summary](#summary)


<a name="documentation" />

## Documentation

The most up-to-date documentation can be found at [www.ledgersync.dev](http://www.ledgersync.dev)

<a name="license" />

## License

The gem is available as open source under the terms of the licenses detailed in `LICENSE.txt`.

<a name="maintainers" />

## Maintainers

A big thank you to our maintainers:

- [@ryanwjackson](https://github.com/ryanwjackson)
- [@jozefvaclavik](https://github.com/jozefvaclavik)
- [@SeanBolt](https://github.com/SeanBolt)
- And the whole [Modern Treasury](https://www.moderntreasury.com) team

<a name="gettingStarted" />

# Getting Started


<a name="installation" />

## Installation
<a name="gemfile" />

### Gemfile
Add this line to your application’s Gemfile:
```
gem 'ledger_sync'
```

And then execute:
```
bundle
```

<a name="directly" />

### Directly
Or install it yourself as:
```
gem install ledger_sync
```

<a name="quickStart" />

## Quick Start

<a name="overview" />

### Overview

To use LedgerSync, you must carry out an **Operation**. The **operation** will be ledger-specific and will require the
following:

1. Client
2. Resource(s)

### 1. Create a Client

Clients are responsible for the authentication and requests for a specific ledger. In this example, we will assume you
are using the QuickBooks Online ledger.

> Note: Each ledger has different requirements for authentication. Please visit the ledger-specific pages to learn more.

```ruby
client = LedgerSync::Ledgers::QuickBooksOnline::Client.new(
  access_token: access_token, # assuming this is defined
  client_id: ENV['QUICKBOOKS_ONLINE_CLIENT_ID'],
  client_secret: ENV['QUICKBOOKS_ONLINE_CLIENT_SECRET'],
  realm_id: ENV['QUICKBOOKS_ONLINE_REALM_ID'],
  refresh_token: refresh_token # assuming this is defined
)
```

### 2. Create resources(s)

Create a resource on which to operate. Some resources have references to other resources. You can
use `Util::ResourcesBuilder` to create resources and relationships from a structured hash.

> Note: Resources are ledger-specific, meaning they may have different attributes and references compared to other ledgers. Please visit [the Reference](/reference) to learn about resource attributes.

```ruby
resource = LedgerSync::Ledgers::QuickBooksOnline::Customer.new(
  DisplayName: 'Sample Customer',
  external_id: customer_external_id # A unique ID from your platform
)
```

### 3. Create an operation

Given our `client` and `resource` from above, we can now create an `Operation`. Operations are typically CRUD-like
methods, typically (though not always) only making a single request.

Operations automatically determine a `Serializer` and `Deserializer`. These serializers are used to translate to and the
from the ruby `Resource` in the format required by the ledger.

```ruby
operation = LedgerSync::Ledgers::QuickBooksOnline::Customer::Operations::Create.new(
  client: client,
  resource: resource
)
```

### 4. Perform the operation

The next step is to perform the operation. You can do this by simply calling `perform`.

```ruby
result = operation.perform # Returns a LedgerSync::OperationResult
```

### 5. Save updates to authentication

Because QuickBooks Online uses Oauth 2, you must always be sure to save the access_token, refresh_token, and expirations
as they can change with any API call. Operations will always save values back to the client.

#### Automatically update values in .env

If you have a `.env` file present in the root directory of your project, the client will automatically comment out old
values and update new values.

If you want to disable this functionality, you can do so by setting `update_dotenv` to `false` when instantiating the
object:

```ruby
client = LedgerSync::Ledgers::QuickBooksOnline::Client.new(
  access_token: access_token, # assuming this is defined
  client_id: ENV['QUICKBOOKS_ONLINE_CLIENT_ID'],
  client_secret: ENV['QUICKBOOKS_ONLINE_CLIENT_SECRET'],
  realm_id: ENV['QUICKBOOKS_ONLINE_REALM_ID'],
  refresh_token: refresh_token, # assuming this is defined
  update_dotenv: false
)

```

<a name="manuallySaveValues" />

#### Manually save values
```ruby
result.operation.client.ledger_attributes_to_save.each do |key, value|
  # save values
end
```

<a name="summary" />

### Summary
That’s it! Assuming proper authentication values and valid values on the resource, this will result in a new customer being created in QuickBooks Online.

There are many other resources and operations that can be performed in QuickBooks Online. For a complete guide of these and other ledgers, visit the Reference.


