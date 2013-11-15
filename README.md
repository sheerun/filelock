# Filelock

Heavily tested, but simple filelocking solution using [flock](http://linux.die.net/man/2/flock) command.

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


## FAQ

*The code is so short. Why shouln't I just copy-paste it?*

Because even such short code can have issues in future. Although it's heavily tested, you may expect new releases of this gem fixing this behavior.

*How it's different from [lockfile](https://github.com/ahoward/lockfile) gem?*

Lockfile is filelocking solution handling NFS filesystems, based on homemade locking solution. Filelock uses [flock](http://linux.die.net/man/2/flock) unix command to handle filelocking.

*How it's different from [cleverua-lockfile](https://github.com/cleverua/lockfile) gem?*

Cleverua removes lockfile after unlocking it. Thas has been proven fatal boath in my tests and in [filelocking advices from the Internet](http://world.std.com/~swmcd/steven/tech/flock.html). If you'll find a way to remove lock file without breaking Filelock tests, I'm glad to accept such pull-request.

## Challenge

Please try to break Filelock in some way (note it doesn't support NFS).

If you show at least one failing test, I'll put your name below:

## License

Filelock is MIT-licensed. You are awesome.
