# -*- encoding : utf-8 -*-
class SubConfig  
  def self.load
    config_file = File.join(Rails.root, "config", "subscription.yml")

    if File.exists?(config_file)
      config = ERB.new(File.read(config_file)).result
      config = YAML.load(config)[Rails.env.to_sym]
      config.keys.each do |key|
        cattr_accessor key
        send("#{key}=", config[key])
      end
    end
  end
end
SubConfig.load
