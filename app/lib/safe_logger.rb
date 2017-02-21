class SafeLogger

  # Methods for introducing logging into production without risking logging-related errors.
  # I've never seen them, but it's a possibility.
  # They take no arguments - the message is passed as a block, so it's rescued too in case the string has buggy interpolation.

  def self.warn(rollbar: true)
    message = yield
    Rails.logger.warn message
    Rollbar.warn(message) if rollbar
    nil
  rescue => e
    (raise e) if test?
    nil
  end

  def self.error(rollbar: true)
    message = yield
    Rails.logger.error message
    Rollbar.error(message) if rollbar
    nil
  rescue => e
    (raise e) if test?
    nil
  end

  def self.info(rollbar: true)
    message = yield
    Rails.logger.info message
    Rollbar.info(message) if rollbar
    nil
  rescue => e
    (raise e) if test?
    nil
  end

end
