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

  it 'runs simple ruby block as usual' do
    answer = 0

    Filelock 'code.lock' do
      answer += 42
    end

    expect(answer).to eq(42)
  end

  it 'returns value returned by block' do
    answer = Filelock 'code.lock' do
      42
    end

    expect(answer).to eq(42)
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

    parallel(500) do
      value = answer
      sleep 0.001
      answer = value + 1
    end

    expect(answer).to eq(500)
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
end
