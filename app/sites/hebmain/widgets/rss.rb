require 'rss/1.0'
require 'rss/2.0'

class Hebmain::Widgets::Rss < WidgetManager::Base
  
  def render_left
    render_preview
  end
  
  def render_full
    items = get_all_items
    div(:class => 'rss'){
      rss_admin
      
      div(:class => 'h1') {
        text get_title
        div(:class =>'h1-right')
        div(:class =>'h1-left')
      }
      picture = get_picture
      text = get_description
      if (!(picture.empty? && text.empty?))
        div(:class => 'header'){
          img(:src => picture, :class =>'Rav Michael Laitman', :alt => 'image') if picture
          text text
          div(:class => 'clear')
        }
      end
      display_entries items, true
    }    
  end
  
  def render_preview
    items = get_all_items
   
    div(:class => 'rss container'){
      rss_admin
      
      h3(:class => 'box_header') {
        #        picture = get_picture
        #        img(:src => picture, :class =>'Rav Michael Laitman', :alt => 'image') if picture
        text get_title
      }
      display_entries items, false
    }
  end
  
  private
  
  def get_rss_items (data)
    rss_items = YAML.load(data) rescue nil
    if rss_items
      rss_items.map do |rss_item|
        {:title => (rss_item.title rescue ''), 
          :url => (rss_item.guid.content rescue ''),
          :aditional_url => (rss_item.link rescue ''),
          :date => (rss_item.pubDate rescue ''),
          :description => (rss_item.description rescue '')
        }
      end
    else
      nil         
    end
  end

  def get_all_items
    content = get_items
    if content.empty?
      CronManager.read_and_save_node_rss(tree_node)
    end

    content = get_items
    return false if content.empty?
    get_rss_items(content)
  end

  def rss_admin
    w_class('cms_actions').new(:tree_node => tree_node, 
      :options => {:buttons => %W{ delete_button edit_button }, 
        :position => 'bottom',
        :button_text => "ניהול ה-RSS: #{get_title}",
        :new_text => 'הוסף RSS חדש'
      }).render_to(doc)
  end

  def display_entries(items, show_description = true)
    if items.empty?
      text _('No entries yet.')
      return
    end
    div(:class => 'entries'){
      items.each do |item|
        div(:class => 'entry'){
          a item[:title], :href => item[:url].empty? ? item[:aditional_url] : item[:url]
          div(:class => 'date'){
            text item[:date].strftime('%d.%m.%y, %H:%m')
          }
          if (show_description)
            div(:class => 'description'){
              rawtext item[:description]
            }
          end
        }
      end
      a get_read_more_text, :href => get_read_more_url, :class => 'more'
    }
  end

end