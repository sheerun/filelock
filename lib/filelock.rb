require 'filelock/version'
require 'timeout'

if RUBY_VERSION <= "1.8.7"
  require 'tempfile'

  def Filelock(lockname, options = {}, &block)
    lockname = lockname.path if lockname.is_a?(Tempfile)
    File.open(lockname, File::RDWR|File::CREAT, 0644) do |file|
      file.flock(File::LOCK_EX)
      Timeout::timeout(options.fetch(:timeout, 60)) { yield }
    end
  end
else
  def Filelock(lockname, options = {}, &block)
    File.open(lockname, File::RDWR|File::CREAT, 0644) do |file|
      file.flock(File::LOCK_EX)
      Timeout::timeout(options.fetch(:timeout, 60)) { yield }
    end
  end
end
