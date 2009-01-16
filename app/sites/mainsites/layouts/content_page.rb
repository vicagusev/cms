class Mainsites::Layouts::ContentPage < WidgetManager::Layout

  attr_accessor :ext_content, :ext_content_header, :ext_title, :ext_description,
    :ext_main_image, :ext_related_items, :ext_kabtv_exist

  def initialize(*args, &block)
    super
    #    @header_top_links = w_class('header').new(:view_mode => 'top_links')
    #    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    #    @header_logo = w_class('header').new(:view_mode => 'logo')
    #    @header_copyright = w_class('header').new(:view_mode => 'copyright')
    @static_tree = w_class('tree').new(:view_mode => 'static')
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    #    @breadcrumbs = w_class('breadcrumbs').new()
    #    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')
    #    @meta_title = w_class('breadcrumbs').new(:view_mode => 'meta_title')
    #    @google_analytics = w_class('google_analytics').new
    #    @newsletter = w_class('newsletter').new(:view_mode => 'sidebar')
    #    @sitemap = w_class('sitemap').new
    #    @send_to_friend = w_class('send_to_friend').new
    #    @direct_link = w_class('shortcut').new
    #    @subscription = w_class('header').new(:view_mode => 'subscription')
    #    @comments = w_class('comments').new
    #    @previous_comments = w_class('comments').new(:view_mode => 'previous')
  end

  def render
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        title ext_title
        meta(:name => 'description', :content => ext_description)
        javascript_include_tag 'jquery', 
        'ui/ui.core.min.js', 'ui/ui.tabs.min.js', 'ui/jquery.color.js',
        'jquery.curvycorners.packed.js', 'jquery.browser.js',
        'jquery.hoverIntent.min.js', 'superfish',
        'flashembed.min.js', 'jq-helpers' #, :cache => 'cache/website'
        if presenter.node.can_edit?
          stylesheet_link_tag 'base-min',
          '../ext/resources/css/ext-all',
          'common/reset.css',
          'rusmain/content_page.css',
          'rusmain/page_admin',
          'rusmain/jquery.tabs.css',
          'rusmain/superfish.css',
          :cache => false
          javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers',
          'ui/ui.sortable.min.js', 'ui/ui.draggable.min.js', 'ui/ui.droppable.min.js'
          javascript {
            rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
          }
        else
          stylesheet_link_tag 'base-min', 
          'common/reset.css',
          'rusmain/content_page.css',
          'rusmain/superfish.css',
          'rusmain/jquery.tabs.css'
          #,
          #:cache => 'cache/website'
        end

        rawtext '<!--[if IE]>'
        stylesheet_link_tag 'rusmain/ie6'
        rawtext '<![endif]-->'
      }
      body {
        if presenter.node.can_edit?
          div(:id => 'command-panel'){
            @dynamic_tree.render_to(self)
            div(:class => 'clear')
          }
          header_class = 'under-command-panel'
        end
        div(:id => 'header', :class => header_class){
          img(:id => 'logo', :src => img_path('logo.gif'), :alt => 'Международная Академия Каббалы')
          img(:id => 'links', :src => img_path('links.gif'), :alt => '')
          img(:id => 'rss', :src => img_path('rss.gif'), :alt => '')
          div(:id => 'divisor')
          select(:id => 'languages'){
            option{rawtext 'Russian'}
            option{rawtext 'English'}
            option{rawtext 'German'}
            option{rawtext 'Spanish'}
            option{rawtext 'Persian'}
          }
          div(:id => 'search'){
            input :type => 'text', :name => 'q', :size => '31', :class => 'text'
            input :type => 'image', :src => img_path('search.gif'), :name => 'sa', :class => 'submit'
            input :type => 'hidden', :name => 'cx', :value => '011301558357120452512:ulicov2mspu'
            input :type => 'hidden', :name => 'ie', :value => 'UTF-8'
            input :type => 'hidden', :name => 'cof', :value => 'FORID:11'
          }
        }
        div(:id => 'nav-empty'){
          nbsp
        }
        div(:id => 'nav'){
          div(:class => 'left-ear')
          div(:class => 'right-ear')

          ul(:class => 'sf-menu'){
            li{
              a(:id => 'homepage', :href => '#'){img(:src => img_path('home.gif'), :alt => 'Homepage')}
            }
            li {
              a(:href => '#'){
                span {rawtext 'Что такое каббала?'}
              }
              ul{
                li {a(:href => '#'){rawtext 'Что такое каббала?'}}
                li {a(:href => '#'){rawtext 'Что такое каббала?'}}
                li {a(:href => '#'){rawtext 'Что такое каббала?'}}
                li {a(:href => '#'){rawtext 'Что такое каббала?'}}
              }
            }
            li {
              a(:href => '#'){
                span {rawtext 'Изучение каббалы'}
              }
            }
            li {
              a(:href => '#'){
                span {rawtext 'Каббала ТВ'}
              }
            }
            li {
              a(:href => '#'){
                span {rawtext 'Курсы очного обучения'}
              }
              ul{
                li {a(:href => '#'){rawtext 'Что такое каббала?'}}
                li {a(:href => '#'){rawtext 'Что такое каббала?'}}
                li {a(:href => '#'){rawtext 'Что такое каббала?'}}
              }
            }
            li {
              a(:href => '#'){
                span {rawtext 'Блог каббалиста М. Лайтмана'}
              }
            }
          }
        }
        div(:id => 'body'){
          div(:id => 'body-left'){
            div(:class => 'side-box-top'){
              rawtext 'Kabbalah for Beginners'
              div(:class => 'left-ear')
              div(:class => 'right-ear')
            }
            div(:class => 'box-content'){
              div(:id => 'static-menu'){
                @static_tree.render_to(self)
                a(:href => '#'){rawtext 'Что такое каббала?'}
                ul(:class => 'minus') {
                  li {a(:href => '#'){rawtext 'Каббала обо всём'}}
                  li {a(:href => '#'){rawtext 'Онлайн-курс'}}
                  li {
                    ul(:class => 'minus') {
                      li {a(:href => '#'){rawtext 'Дистанционное обучение'}}
                      li {a(:href => '#'){rawtext 'Онлайн-курс для'}}
                      li(:class => 'selected') {a(:href => '#'){rawtext 'Дистанционное обучение с каббалистом'}}
                      li {a(:href => '#'){rawtext 'Oбучение'}}
                    }
                  }
                  li {
                    ul(:class => 'plus') { li {a(:href => '#'){rawtext 'Курсы очного обучения'}} }
                  }
                  li {a(:href => '#'){rawtext 'Углублённое изучение'}}
                }
                a(:href => '#'){rawtext 'Диалог с каббалистом'}
                a(:href => '#'){rawtext 'Блог каббалиста М. Лайтмана'}
                ul(:class => 'plus') { li {a(:href => '#'){rawtext 'Дневник актуальных событий для начинающих'}} }
                a(:href => '#'){rawtext 'Онлайн-курс для начинающих'}
                ul(:class => 'plus') { li {a(:href => '#'){rawtext 'Дистанционное обучение'}} }
                a(:href => '#'){rawtext 'Курсы очного обучения'}
                a(:href => '#'){rawtext 'Углублённое изучение каббалы'}
              }
            }
            div(:class => 'side-box'){
              h3 'Newsletter'
              div(:class => 'box-content'){
                rawtext 'tv'
              }
            }
            div(:class => 'side-box'){
              h3 'Updates'
              div(:class => 'box-content'){
                rawtext 'Bold headline'
                br
                rawtext 'A few lines of text A few lines of text A few lines of text A few lines of text A few lines of text A few lines of text '
                br
                a(:href => ''){rawtext 'A link to something'}
              }
            }
          }
          div(:id => 'body-middle'){
            div(:class => 'mid-box-top'){
              rawtext 'Recent Lessons'
              div(:class => 'left-ear')
              div(:class => 'right-ear')
            }
            div(:id => 'mid-content'){
              make_sortable(:selector => ".mid-content", :axis => 'y') {
                self.ext_content.render_to(self)
              }
            }
          }
        }
        div(:id => 'footer'){
          rawtext 'Footer'
        }
        #        @google_analytics.render_to(self)
      }
    }
  end
  
  private
  
  def right_column_resources
    @tree_nodes_right ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['site_updates', 'video_gallery'],
      :depth => 1,
      :placeholders => ['right'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end
  
  def left_column_resources
    @tree_nodes_left ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['rss'],
      :depth => 1,
      :placeholders => ['left'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end
  
  def middle_column_resources
    @tree_nodes_middle ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['content_preview', 'title'],
      :depth => 1,
      :placeholders => ['middle'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end
  
  def kabbalah_media_resources
    @kabbalah_media_nodes ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['media_rss'],
      :depth => 1,
      :placeholders => ['lesson'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

  def kabtv_resources
    @kabtv_nodes ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['kabtv'],
      :depth => 1,
      :placeholders => ['home_kabtv'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

end 
