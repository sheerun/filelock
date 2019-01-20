require 'timeout'
require 'filelock/version'
require 'filelock/exec_timeout'
require 'filelock/wait_timeout'
require 'tempfile'

if RUBY_PLATFORM == "java"
  def Filelock(lockname, options = {}, &block)
    lockname = lockname.path if lockname.is_a?(Tempfile)
    # Options for file modes, lock  options
    modes = options.fetch(:modes, File::RDWR|File::CREAT)
    lock_options = options.fetch(:lock_options, File::LOCK_EX)
    locked = nil
    File.open(lockname, modes, 0644) do |file|
      # Non-blocking mode was set, don't worry about the wait timeout.
      if (lock_options & File::LOCK_NB == File::LOCK_NB)
        locked = file.flock(lock_options)
      else
        Thread.pass until Timeout::timeout(options.fetch(:wait, 60*60*24), Filelock::WaitTimeout) {file.flock(lock_options)}
      end
      # Only false if Non-blocking mode was set and we failed to acquire the lock.
      if locked == false
        locked
      else
        Timeout::timeout(options.fetch(:timeout, 60), Filelock::ExecTimeout) { yield file }
      end
    end
  end
else
  def Filelock(lockname, options = {}, &block)
    lockname = lockname.path if lockname.is_a?(Tempfile)
    modes = options.fetch(:modes, File::RDWR|File::CREAT)
    # A logical OR of the locking constants shown here: https://ruby-doc.org/core-2.3.1/File.html#method-i-flock
    lock_options = options.fetch(:lock_options, File::LOCK_EX)
    locked = nil
    File.open(lockname, modes, 0644) do |file|
      # Non-blocking mode was set, don't worry about the wait timeout.
      if (lock_options & File::LOCK_NB == File::LOCK_NB)
        locked = file.flock(lock_options)
      else
        Timeout::timeout(options.fetch(:wait, 60*60*24), Filelock::WaitTimeout) {file.flock(lock_options)}
      end
      # Only false if Non-blocking mode was set and we failed to acquire the lock.
      if locked == false
        locked
      else
        Timeout::timeout(options.fetch(:timeout, 60), Filelock::ExecTimeout) { yield file }
      end
    end
  end
end
