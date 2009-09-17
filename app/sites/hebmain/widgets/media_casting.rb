class Hebmain::Widgets::MediaCasting < WidgetManager::Base
    
  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }, :position => 'bottom'}).render_to(self)
  	
    title = get_title
    url = get_url
    hide_download_link = get_hide_download_link
    div(:class => 'mediacasting'){
	
      a(:class => 'hide-player', :href => ''){
        img :src => '/images/delete.gif', :alt => '', :style => 'vertical-align:middle;'
        text 'הפסק'
      }
      if (hide_download_link.is_a?(String) && hide_download_link.empty?) || (not hide_download_link)
        a(:class => 'media-download', :href => url){
          img :src => '/images/download.jpg', 
            :alt => '', 
            :style => 'vertical-align:middle;'
          text '  הורד'
        }
      end
		 
      div(:class => 'toggle-media'){
        a(:href => url, :class => 'media'){
          text title
        }
      }
	  	 
      a(:class => 'show-player', :href => ''){
        text title
      }
	  		
    }
	    
  end

end
