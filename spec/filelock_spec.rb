require 'filelock'
require 'tempfile'
require 'timeout'

describe Filelock do

  def parallel(n = 2, templock = nil, &block)
    Timeout::timeout(5) do
      templock ||= Tempfile.new(['sample', '.lock'])

      (1..n).map do
        Thread.new do
          Filelock(templock, &block)
        end
      end.map(&:join)
    end
  end

  def parallel_forks(n = 2, templock = nil, &block)
    Timeout::timeout(5) do
      templock ||= Tempfile.new(['sample', '.lock'])

      (1..n).map do
        fork {
          Filelock(templock, &block)
        }
      end.map do |pid|
        Process.waitpid(pid)
      end
    end
  end

  it 'runs simple ruby block as usual' do
    Dir.mktmpdir do |dir|
      lockpath = File.join(dir, 'sample.lock')
      answer = 0

      Filelock lockpath do
        answer += 42
      end

      expect(answer).to eq(42)
    end
  end

  it 'returns value returned by block' do
    Dir.mktmpdir do |dir|
      lockpath = File.join(dir, 'sample.lock')
      answer = Filelock lockpath do
        42
      end

      expect(answer).to eq(42)
    end
  end

  it 'runs in parallel without race condition' do
    answer = 0

    parallel(2) do
      value = answer
      sleep 0.1
      answer = value + 21
    end

    expect(answer).to eq(42)
  end

  it 'handels high amount of concurrent tasks' do
    answer = 0

    parallel(100) do
      value = answer
      sleep 0.001
      answer = value + 1
    end

    expect(answer).to eq(100)
  end

  it 'creates lock file on disk during block execution' do
    Dir.mktmpdir do |dir|
      lockpath = File.join(dir, 'sample.lock')
      parallel(2, lockpath) do
        expect(File.exist?(lockpath)).to eq(true)
      end
    end
  end

  it 'runs in parallel without race condition' do
    Dir.mktmpdir do |dir|
      lockpath = File.join(dir, 'sample.lock')

      answer = 0

      begin
        Filelock(lockpath) do
          raise '42'
        end
      rescue RuntimeError
      end

      Filelock(lockpath) do
        answer += 42
      end

      expect(answer).to eq(42)
    end
  end

  it 'times out after specified number of seconds' do
    Dir.mktmpdir do |dir|
      lockpath = File.join(dir, 'sample.lock')

      answer = 42

      begin
        Filelock lockpath, :timeout => 1 do
          sleep 2
          answer = 0
        end
      rescue Timeout::Error
      end

      expect(answer).to eq(42)
    end
  end

  it 'should work for multiple processes' do
    File.write('/tmp/number.txt', '0')

    parallel_forks(6) do
      number = File.read('/tmp/number.txt').to_i
      sleep 0.3
      File.write('/tmp/number.txt', (number + 7).to_s)
    end

    number = File.read('/tmp/number.txt').to_i

    expect(number).to eq(42)
  end

  it 'should handle heavy forking' do
    File.write('/tmp/number.txt', '0')

    parallel_forks(100) do
      number = File.read('/tmp/number.txt').to_i
      sleep 0.001
      File.write('/tmp/number.txt', (number + 1).to_s)
    end

    number = File.read('/tmp/number.txt').to_i

    expect(number).to eq(100)
  end

  it 'should unblock files when killing processes' do
    Dir.mktmpdir do |dir|
      lockpath = File.join(dir, 'sample.lock')

      Dir.mktmpdir do |dir|
        pid = fork {
          Filelock lockpath do
            sleep 10
          end
        }

        sleep 0.5

        answer = 0

        thread = Thread.new {
          Filelock lockpath do
            answer += 42
          end
        }

        sleep 0.5

        expect(answer).to eq(0)
        Process.kill(9, pid)
        thread.join

        expect(answer).to eq(42)
      end
    end
  end

  it 'should handle Pathname as well as string path' do
    Dir.mktmpdir do |dir|
      lockpath = Pathname.new(File.join(dir, 'sample.lock'))

      answer = 0
      Filelock lockpath do
        answer += 42
      end

      expect(answer).to eq(42)
    end
  end
end
