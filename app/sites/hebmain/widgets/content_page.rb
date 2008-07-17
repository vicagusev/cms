class Hebmain::Widgets::ContentPage < WidgetManager::Base

  def render_large
    @image_src = get_preview_image(:image_name => 'large')
    show_content_page(false)  #### - disabled by Dudi's request
  end

  def render_medium
    @image_src = get_preview_image(:image_name => 'medium')
    show_content_page(false)  #### - disabled by Dudi's request
  end

  def render_small
    @image_src = get_preview_image(:image_name => 'small')
    show_content_page(false)
  end

  def gg_analytics_tracking (name_of_link = '')
    if presenter.is_homepage? 
      {:onclick => "javascript:urchinTracker('/homepage/#{name_of_link}');"}
    else
      {}
    end
  end

  def show_content_page(display_h2 = true)
    main_tree_node = tree_node.resource.tree_nodes.main
    url = get_page_url(main_tree_node)
    url_name = url.split('/').reverse[0];
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(doc)
    if @image_src
      a({:href => url}.merge!(gg_analytics_tracking(url_name))){
        img(:class => 'img', :src => @image_src, :alt => get_preview_image_alt, :title => get_preview_image_alt) 
      }
    end
    preview_title = get_preview_title rescue ''
    large_title = get_title rescue ''
    
    final_title = !preview_title.empty? ? preview_title : (!large_title.empty? ? large_title : '')
    unless final_title.empty?
      h1{
        a({:href => url}.merge!(gg_analytics_tracking(url_name))) {
    	  text final_title
        } 
      }
    end
    h2 get_small_title if display_h2 && !get_small_title.empty?
    div(:class => 'descr') { text get_description } unless get_description.empty?
    
    klass = @image_src ? 'more' : 'more_no_img'
    unless presenter.site_settings[:use_advanced_read_more]
      a({:class => klass, :href => url}.merge!(gg_analytics_tracking(url_name))) { text "לכתבה המלאה" }
    else
      is_video, is_audio, is_article = is_video_audio_article
      if is_article
        a({:class => klass, :href => url}.merge!(gg_analytics_tracking(url_name))) { 
          text "לכתבה המלאה"
          img(:src => img_path('video.png'), :alt => '') if is_video
          img(:src => img_path('audio.png'), :alt => '') if is_audio
          img(:src => img_path('empty.gif'), :alt => '') if !is_video && !is_audio
        }
      else # not article
        if is_video || is_audio
          a({:class => klass, :href => url}.merge!(gg_analytics_tracking(url_name))) { 
            if is_video
              text = 'לצפייה'
              image = 'video.png'
            else
              text = 'להאזנה'
              image = 'audio.png'
            end
            span{text text}
            img(:src => img_path(image), :alt => '')
          }
        end
      end
    end
  end

  def is_video_audio_article
    tree_nodes = TreeNode.get_subtree(
      :parent => tree_node.main.id, 
      :resource_type_hrids => ['video', 'article', 'audio'], 
      :depth => 1
    ) 
    is_article = !get_body.empty?
    is_audio = false
    is_video = false
    tree_nodes.each { |tree_node|
      case tree_node.resource.resource_type.hrid
      when 'audio'
        is_audio = true
      when 'video'
        is_video = true
      when 'article'
        is_article = true
      end
      if is_video && is_audio && is_article
        return true, true, true
      end
    }
    
    return is_video, is_audio, is_article
  end
  
end
