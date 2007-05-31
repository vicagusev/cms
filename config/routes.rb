ActionController::Routing::Routes.draw do |map|

  map.resources :languages

  map.resources :label_types
  map.resources :label_types do |label_types|
	  label_types.resources :labels, :label_type_descs


	end


end
