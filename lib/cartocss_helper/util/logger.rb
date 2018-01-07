# frozen_string_literal: true

require 'logger'

module Log
  @@_logger_ = Logger.new(STDOUT)

  def self.logger
    @@_logger_
  end

  def self.info(message = '')
    logger.info(message)
  end

  def self.warn(message = '')
    logger.warn(message)
  end

  @@_logger_.formatter = proc do |_severity, _datetime, _progname, msg|
    fileLine = ''
    caller.each do |clr|
      unless /\/logger.rb:/ =~ clr
        fileLine = clr
        break
      end
    end
    fileLine = fileLine.split(':in `', 2)[0]
    fileLine.sub!(/:(\d)/, '(\1')
    "#{fileLine}) : #{msg}\n"
  end
end
