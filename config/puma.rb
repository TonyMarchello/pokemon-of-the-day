max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count).to_i
threads min_threads_count, max_threads_count

# Keep the app in single-worker mode on Render's free instance.
# The free plan is small enough that extra workers can cause 502 errors.
workers 1

environment ENV.fetch("RAILS_ENV", "development")

bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"
plugin :tmp_restart
