require "filelock/version"

def Filelock(lockname, options = {}, &block)
  File.open(lockname, File::RDWR|File::CREAT, 0644) do |file|
    file.flock(File::LOCK_EX)
    Timeout::timeout(options.fetch(:timeout, 60)) { yield }
  end
end
