require 'filelock/version'
require 'timeout'
require 'tempfile'

if RUBY_PLATFORM == "java"
  def Filelock(lockname, options = {}, &block)
    lockname = lockname.path if lockname.is_a?(Tempfile)
    File.open(lockname, File::RDWR|File::CREAT, 0644) do |file|
      Thread.pass until file.flock(File::LOCK_EX)
      Timeout::timeout(options.fetch(:timeout, 60)) { yield }
    end
  end
else
  def Filelock(lockname, options = {}, &block)
    lockname = lockname.path if lockname.is_a?(Tempfile)
    File.open(lockname, File::RDWR|File::CREAT, 0644) do |file|
      file.flock(File::LOCK_EX)
      Timeout::timeout(options.fetch(:timeout, 60)) { yield }
    end
  end
end
