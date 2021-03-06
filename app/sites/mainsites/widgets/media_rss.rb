require 'rss/1.0'
require 'rss/2.0'

class Mainsites::Widgets::MediaRss < WidgetManager::Base

  def initialize(*args, &block)
    super
    @language = get_language
    @web_node_url = get_page_url(@presenter.node)
  end

  def render_left
    id = tree_node.id
    div(:id => "rss_media#{id}"){}
    javascript {
      rawtext "$('#rss_media#{id}').load('#{@web_node_url}',{view_mode:'ajax','options[widget]':'media_rss','options[widget_node_id]':#{tree_node.id}})"
    }
  end

  def render_ajax
    lessons = lesson_validation
    return rawtext('') if lessons.nil?
    
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(self)
    
    days_num = get_days_num rescue 1
     
    30.times do |j|
      curr_date = (Date.today - j).strftime('%d.%m.%Y')
      
      selected_lessons = lessons['lessons']['lesson'].select { |lesson|
        lesson['date'] && lesson['date'] == curr_date && 
          lesson['files'] && #lesson['files'].is_a?(Hash) &&
        lesson['files']['file'] #&& lesson['files']['file'].is_a?(Hash) && !lesson['files']['file'].empty?
      } 

      unless selected_lessons.empty?
        curr_date_to_show = (Date.today - j).strftime('%d.%m.%y')
        if has_lesson_in_site_language(selected_lessons)
          if (get_group_by_date)
            lesson_show(selected_lessons, curr_date_to_show)
          else
            selected_lessons.each_with_index { |selected_lesson, index|
              lesson_show(Array.new(1,selected_lesson), curr_date_to_show, index) 
            }
          end
          days_num = days_num - 1
          break if days_num == 0
        end
      end
    end
  end
  
  def render_full
    lessons = lesson_validation
    return rawtext('') if lessons.nil?
    
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button edit_button }, :position => 'bottom'}).render_to(self)
    
    days_num = get_days_num rescue 1
    table(:class => "media_rss") {
      thead {
        tr {
          th(:class => 'top-right-corner'){ text _(:date)}
          th _(:name)
          th _(:video)
          th _(:audio)
          th _(:text)
          th(:class => 'top-left-corner'){ text _(:picture)}
        }
      }
	      
      30.times { |j|
        curr_date = (Date.today - j).strftime('%d.%m.%Y')
	      
        if lessons['lessons']['lesson'].kind_of?(Array)
					selected_lessons = lessons['lessons']['lesson'].select { |lesson|
						lesson['date'] && (lesson['date'] == curr_date) && 
							lesson['files'] && lesson['files']['file']
					} 
				else
					lesson = lessons['lessons']['lesson']
					if lesson
						date = Date.parse(lesson['date']).strftime('%d.%m.%Y')
						selected_lessons = [lesson] if date && (date == curr_date) &&
              lesson['files'] && lesson['files']['file']
					end
				end
	
        unless selected_lessons.empty?
          curr_date_to_show = (Date.today - j).strftime('%d.%m.%y')
          if has_lesson_in_site_language(selected_lessons)
            if (get_group_by_date)
              lessons_show_in_table(selected_lessons, curr_date_to_show)
            else
              selected_lessons.each { |selected_lesson|
                lessons_show_in_table(Array.new(1,selected_lesson), curr_date_to_show)   
              }
            end
            days_num = days_num - 1
            break if days_num == 0
          end
        end
      }
    }
  end
  
  private
  
  def get_rss_items (data)
    YAML.load(data) rescue nil
  end
    
  def has_lesson_in_site_language(lessons)
    lessons.each_with_index { |lesson, i|
      files_array = lesson['files']['file'].is_a?(Hash) ? Array.new(1,lesson['files']['file']) : lesson['files']['file']
      files_array.each { |file| 
        path = file['path'] rescue ''
        unless path.empty?
          if file['language'] && file['language'] == get_language
            return true
          end
        end
      }
    }
    return false
  end

  def get_language
    lang = presenter.site_settings[:language] rescue 'english'
    return (lang[0..2]).upcase
  end
  
  def is_media_file(path, extension)
    len_path = path.length
    len_ext  = extension.length
    if (len_path < len_ext)
      return false
    end
    range = Range.new(len_path - len_ext, len_path, true)
    if path[range] == extension
      return true
    else
      return false
    end
  end
  
  def lesson_show(selected_lessons, curr_date, index = 0)
    div(:class => 'toggle', :tree_node => tree_node.id.to_s + index.to_s, :onclick => "_gaq.push(['_trackEvent', 'daily lesson window', 'open']);"){
      img(:class => 'x-plus', :src => '/images/hebmain/jquery/s.gif',:alt => '')
      text get_title if get_title
      span(:class => 'date') {text ' ' + curr_date.to_s}
    }
    
    ul(:id => 'lesson-' + tree_node.id.to_s + index.to_s, :style => 'display:none;'){
      selected_lessons.each { |lesson|
        # Find video, audio, sirtut
        wmv_href, mp4_href, audio_href, text_href, sirtut_href = lesson_links(lesson)
        
        if !wmv_href.empty? || !mp4_href.empty? || !audio_href.empty? || !sirtut_href.empty?
          li(:class => 'item'){
            img(:class => 'x-', :src => '/images/hebmain/jquery/s.gif',:alt => '')
            text lesson['title']
            div(:class => 'services'){
              a(:class => 'mp4', :href => mp4_href, :onclick => "_gaq.push(['_trackEvent', 'daily lesson sidebar', 'play', 'mp4']);"){span {text 'mp4'} } unless wmv_href.empty?
              a(:class => 'video', :href => wmv_href, :onclick => "_gaq.push(['_trackEvent', 'daily lesson sidebar', 'play', 'wmv']);"){span {text 'wmv'} } unless wmv_href.empty?
              a(:class => 'audio', :href => audio_href, :onclick => "_gaq.push(['_trackEvent', 'daily lesson sidebar', 'play', 'mp3']);"){span {text 'mp3'} } unless audio_href.empty?
              a(:class => 'text', :href => text_href, :onclick => "_gaq.push(['_trackEvent', 'daily lesson sidebar', 'play', 'txt']);"){span {text _(:text)} } unless text_href.empty?
              a(:class => 'sketch', :href => sirtut_href, :onclick => "_gaq.push(['_trackEvent', 'daily lesson sidebar', 'play', 'zip']);"){span {text _(:picture)} } unless sirtut_href.empty?
            }
          }
        end
      }
    }
  end
  
  def lessons_show_in_table(selected_lessons, curr_date)
    selected_lessons.each_with_index { |lesson, i|
      wmv_href, mp4_href, audio_href, text_href, sirtut_href = lesson_links(lesson)
               
      tr(:class => 'mouse-grey-over') {
        td(:class => 'right-cell date-rss'){text curr_date.to_s}
        td(:class => 'name-cell'){text lesson['title'] || ''}
        
        td(:class => 'icon-cell icon-rss'){
          a(:href => wmv_href, :onclick => "_gaq.push(['_trackEvent', 'daily lesson category_video', 'play']);") { text 'wmv' } unless wmv_href.empty?
          br
          a(:href => mp4_href, :onclick => "_gaq.push(['_trackEvent', 'daily lesson category_video', 'play']);") { text 'mp4' } unless mp4_href.empty?
        }
        td(:class => 'icon-cell icon-rss'){
          a(:href => audio_href, :onclick => "_gaq.push(['_trackEvent', 'daily lesson category_audio', 'play']);") {
            img(:class => 'img', :src => img_path('audio.png'), :alt => '') unless audio_href.empty?
          }
        }
        td(:class => 'icon-cell icon-rss'){
          a(:href => text_href) {
            img(:class => 'img', :src => img_path('text.png'), :alt => 'doc') unless text_href.empty?
          }
        }
        td(:class => 'left-cell icon-rss') {
          a(:href => sirtut_href) { 
            img(:class => 'img', :src => img_path('skric.png'), :alt => '') unless sirtut_href.empty?
          }
        }
      }
    }
  end
  
  def lesson_validation
    content = get_items rescue nil
    if content.empty? || content.nil?
      CronManager.read_and_save_node_media_rss(tree_node, get_language)
    end
    
    content = get_items rescue nil
    return nil if content.empty? || content.nil?
    lessons = get_rss_items(content)
    if lessons.nil? || !lessons.is_a?(Hash) || lessons.empty?
      !lessons['lessons'] || !lessons['lessons'].is_a?(Hash) ||  
        !lessons['lessons']['lesson'] || !lessons['lessons']['lesson'].is_a?(Hash) 
      return nil
    end
    return lessons
  end
  
  def lesson_links(lesson)
    wmv_href = ''
    mp4_href = ''
    audio_href = ''
    text_href = ''
    sirtut_href = ''
          
    audio_found = false
    files_array = lesson['files']['file'].is_a?(Hash) ? Array.new(1,lesson['files']['file']) : lesson['files']['file']
    files_array.each do |file| 
      path = file['path'] rescue ''
      unless path.empty?
        if file['language'] && file['language'] == get_language
          if is_media_file(path, 'zip')
            sirtut_href = path
          else 
            if is_media_file(path, 'doc')
              text_href = path
            else
              if is_media_file(path, 'wmv')
                wmv_href = path
              elsif is_media_file(path, 'mp4')
                mp4_href = path
              else
                if is_media_file(path, 'mp3') && !is_media_file(path, '96k.mp3')
                  audio_href = path
                  audio_found = true
                else
                  if !audio_found && is_media_file(path, '96k.mp3')
                    audio_href = path
                  end
                end
              end
            end
          end
        end
      end
    end
    return wmv_href, mp4_href, audio_href, text_href, sirtut_href
  end
  
end
