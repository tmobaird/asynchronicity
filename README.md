# Asynchronicity

This is my test attempt at rebuilding a simple version of Sidekiq
for the chance to familiarize myself with ways to use Redis.

- [x] Long Poll Redis
- [x] Support enqueueing via console
- [x] Consuming w/ doing something
  - [x] Need to figure out serialization
- [x] Consuming w/ plain logging
- [x] Consuming w/ failed jobs
- [x] Error message for failures
- [x] Consuming w/ retries
- [ ] Completed Jobs Count
- [ ] Configuration metrics, delays, etc.

# Web App
- [x] page to show list of queues, a link to queue up work, and some metrics
- [x] a page with a form to enqueue work
- [x] an ability to view a queue
