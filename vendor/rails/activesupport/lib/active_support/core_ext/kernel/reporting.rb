# -*- encoding : utf-8 -*-
module Kernel
  # Sets $VERBOSE to nil for the duration of the block and back to its original value afterwards.
  #
  #   silence_warnings do
  #     value = noisy_call # no warning voiced
  #   end
  #
  #   noisy_call # warning voiced
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  # Sets $VERBOSE to true for the duration of the block and back to its original value afterwards.
  def enable_warnings
    old_verbose, $VERBOSE = $VERBOSE, true
    yield
  ensure
    $VERBOSE = old_verbose
  end

  # For compatibility
  def silence_stderr #:nodoc:
    silence_stream(STDERR) { yield }
  end

  # Silences any stream for the duration of the block.
  #
  #   silence_stream(STDOUT) do
  #     puts 'This will never be seen'
  #   end
  #
  #   puts 'But this will'
  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end

  # Blocks and ignores any exception passed as argument if raised within the block.
  #
  #   suppress(ZeroDivisionError) do
  #     1/0
  #     puts "This code is NOT reached"
  #   end
  #
  #   puts "This code gets executed and nothing related to ZeroDivisionError was seen"
  def suppress(*exception_classes)
    begin yield
    rescue Exception => e
      raise unless exception_classes.any? { |cls| e.kind_of?(cls) }
    end
  end
end
