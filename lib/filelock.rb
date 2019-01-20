require 'timeout'
require 'filelock/version'
require 'filelock/exec_timeout'
require 'filelock/wait_timeout'
require 'tempfile'

if RUBY_PLATFORM == "java"
  def Filelock(lockname, options = {}, &block)
    lockname = lockname.path if lockname.is_a?(Tempfile)
    modes = options.fetch(:modes, File::RDWR|File::CREAT)
    lock_options = options.fetch(:lock_options, File::LOCK_EX)
    File.open(lockname, modes, 0644) do |file|
      Thread.pass until Timeout::timeout(options.fetch(:wait, 60*60*24), Filelock::WaitTimeout) { file.flock(lock_options) }
      Timeout::timeout(options.fetch(:timeout, 60), Filelock::ExecTimeout) { yield file }
    end
  end
else
  def Filelock(lockname, options = {}, &block)
    lockname = lockname.path if lockname.is_a?(Tempfile)
    File.open(lockname, modes, 0644) do |file|
      Timeout::timeout(options.fetch(:wait, 60*60*24), Filelock::WaitTimeout) { file.flock(lock_options) }
      Timeout::timeout(options.fetch(:timeout, 60), Filelock::ExecTimeout) { yield file }
    end
  end
end
