ArchivesSpace::Application.routes.draw do

  [AppConfig[:frontend_proxy_prefix], AppConfig[:frontend_prefix]].uniq.each do |prefix|

    scope prefix do
      match('/plugins/instance_joiner' => 'instance_joiner#index', :via => [:get])
      match('/plugins/instance_joiner/create' => 'instance_joiner#create', :via => [:post])
    end
  end
end
