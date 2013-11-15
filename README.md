# Filelock

Heavily tested, but simple filelocking solution using `flock` command.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'filelock'
```

## Usage

```ruby
Filelock '/tmp/path/to/lock' do
  # do blocking operation
end
```

You can also pass the timeout for blocking operation (default is 60 seconds):

```ruby
Filelock '/tmp/path/to/lock', :timeout => 10 do
  # do blocking operation
end
```

Note that lock file directory must already exist.

## Challenge

Please try to break this filelocking solution in some way (note it doesn't support NFS). If you show at least one failing test, I'll put your name below:

## License

Filelock is MIT-licensed. You are awesome.
