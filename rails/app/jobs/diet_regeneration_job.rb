# Deprecated — diet regeneration is now handled directly in DietsController#regenerate
class DietRegenerationJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # no-op: retained for backwards compatibility with any queued jobs
  end
end
