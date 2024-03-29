# -*- encoding : utf-8 -*-
class MigrationGenerator < Rails::Generator::NamedBase  
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :assigns => get_local_assigns
    end
  end

  
  private  
    def get_local_assigns
      returning(assigns = {}) do
        if class_name.underscore =~ /^(add|remove)_.*_(?:to|from)_(.*)/
          assigns[:migration_action] = $1
          assigns[:table_name]       = $2.pluralize
        else
          assigns[:attributes] = []
        end
      end
    end
end
