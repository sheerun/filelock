# 1.1.1

- fix: Load timeout module before using it
- pass locked file to block provided to Filelock

# 1.1.0

- Add `:wait` flag for lock-acquiting timeout
- Add two new timeout exceptions: `FileLock::ExecTimeout` and `FileLock::WaitTimeout`

# 1.0.3

Fix for rubinius

# 1.0.2

Make filelock working for jruby

# 1.0.1

Test and fix more ruby versions
