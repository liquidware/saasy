# -*- encoding : utf-8 -*-
require 'optparse'

options = { :environment => (ENV['RAILS_ENV'] || "development").dup }
code_or_file = nil

ARGV.clone.options do |opts|
  script_name = File.basename($0)
  opts.banner = "Usage: #{$0} [options] ('Some.ruby(code)' or a filename)"

  opts.separator ""

  opts.on("-e", "--environment=name", String,
          "Specifies the environment for the runner to operate under (test/development/production).",
          "Default: development") { |v| options[:environment] = v }

  opts.separator ""

  opts.on("-h", "--help",
          "Show this help message.") { $stderr.puts opts; exit }

  if RUBY_PLATFORM !~ /mswin/
    opts.separator ""
    opts.separator "You can also use runner as a shebang line for your scripts like this:"
    opts.separator "-------------------------------------------------------------"
    opts.separator "#!/usr/bin/env #{File.expand_path($0)}"
    opts.separator ""
    opts.separator "Product.find(:all).each { |p| p.price *= 2 ; p.save! }"
    opts.separator "-------------------------------------------------------------"
  end

  opts.order! { |o| code_or_file ||= o } rescue retry
end

ARGV.delete(code_or_file)

ENV["RAILS_ENV"] = options[:environment]
RAILS_ENV.replace(options[:environment]) if defined?(RAILS_ENV)

require RAILS_ROOT + '/config/environment'

begin
  if code_or_file.nil?
    $stderr.puts "Run '#{$0} -h' for help."
    exit 1
  elsif File.exist?(code_or_file)
    eval(File.read(code_or_file), nil, code_or_file)
  else
    eval(code_or_file)
  end
ensure
  if defined? Rails
    Rails.logger.flush if Rails.logger.respond_to?(:flush)
  end
end
