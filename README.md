# :camera: Snapshot Testing

Snapshot testing for all Ruby test frameworks.

### Features

- Human-readable snapshots
- Supports RSpec, Minitest, and Test::Unit
- Custom serializers

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'snapshot_testing'
```

And then execute:

    $ bundle

## Usage

The examples below will show you how to use `snapshot_testing` in each testing framework.

On the first test run, a [`.snap` file](examples/__snapshots__/rspec.rb.snap) will be created. The contents of the `.snap` file will be compared to the value under test on subsequent test runs.

If the value in the snapshot is not equal to the value under test, the test will fail. You can update the snapshots by rerunning the test suite by setting `UPDATE_SNAPSHOTS=1` in the environment.

### RSpec

Configure `snapshot_testing` in your `spec_helper.rb`:

```ruby
require 'snapshot_testing/rspec'

RSpec.configure do |config|
  config.include SnapshotTesting::RSpec
end
```

Now, you can take snapshots:

```ruby
RSpec.describe "Example" do
  it "takes a snapshot" do
    expect("hello").to match_snapshot
    expect("goodbye").to match_snapshot
  end
end
```

### Minitest

```ruby
require 'minitest/autorun'
require 'snapshot_testing/minitest'

class ExampleTest < Minitest::Test
  include SnapshotTesting::Minitest

  def test_takes_a_snapshot
    assert_snapshot "hello"
    assert_snapshot "goodbye"
  end
end

class ExampleSpec < Minitest::Spec
  include SnapshotTesting::Minitest

  it "takes a snapshot" do
    "hello".must_match_snapshot
    "goodbye".must_match_snapshot
  end
end
```

### Test::Unit

```ruby
require 'test/unit'
require 'snapshot_testing/test_unit'

class ExampleTest < Test::Unit::TestCase
  include SnapshotTesting::TestUnit

  def test_snapshot
    assert_snapshot "hello"
    assert_snapshot "goodbye"
  end
end
```

## Custom Serializers

Sometimes, you might want to define how objects get serialized as a snapshot. For example, you could define a custom serializer to convert an object to YAML.

```ruby
class PersonSerializer
  def accepts?(object)
    object.is_a? Person
  end

  def dump(object)
    YAML.dump(object)
  end
end

SnapshotTesting::Snapshot.use PersonSerializer.new
```

Now, in your test, you can take snapshots of `Person` objects:

```ruby
it "serializes a person" do
  expect(Person.new).to match_snapshot
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rzane/snapshot_testing.
