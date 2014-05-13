require "logger"

class PLogger
  def initialize *args
    @stdout = Logger.new STDOUT
    @log    = Logger.new *args
  end

  %w(debug info warn error fatal).each do |level|
    define_method(level) do |*args|
      [@stdout, @log].all? do |output|
        output.send level, *args
      end
    end
  end
end
