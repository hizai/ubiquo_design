require 'ubiquo_design'

config.after_initialize do
  UbiquoDesign::Connectors.load!
end

ActiveSupport::Dependencies.load_paths << Rails.root.join("app", "models", "widgets")

Ubiquo::Plugin.register(:ubiquo_design, directory, config) do |config|
  config.add :pages_elements_per_page
  config.add_inheritance :pages_elements_per_page, :elements_per_page
  config.add :design_access_control, lambda{
    access_control :DEFAULT => "design_management"
  }
  config.add :sitemap_access_control, lambda{
    access_control :DEFAULT => "sitemap_management"
  }
  config.add :design_permit, lambda{
    permit?("design_management")
  }
  config.add :sitemap_permit, lambda{
    permit?("sitemap_management")
  }
  config.add :static_pages_permit, lambda{
    permit?("static_pages_management")
  }  
  config.add :page_string_filter_enabled, true
  config.add :pages_default_order_field, 'pages.url_name'
  config.add :pages_default_sort_order, 'ASC'
  config.add :connector, :standard

  config.add :cache_manager_class, lambda{
#    case Rails.env
#    when 'development', 'test'
#      UbiquoDesign::CacheManagers::Filesystem
#    else
      UbiquoDesign::CacheManagers::Memcache
#    end
  }

  config.add :memcache, {:server => '127.0.0.1', :timeout => 0}
end

groups = Ubiquo::Config.get :model_groups
Ubiquo::Config.set :model_groups, groups.merge(
  :ubiquo_design => %w{assets asset_relations automatic_menus blocks
          widgets menu_items pages})

