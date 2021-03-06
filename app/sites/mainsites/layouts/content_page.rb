class Mainsites::Layouts::ContentPage < WidgetManager::Layout

  attr_accessor :ext_content, :ext_content_header, :ext_title, :ext_description,
    :ext_main_image, :ext_related_items, :ext_kabtv_exist

  def initialize(*args, &block)
    super
    @header_search = w_class('header').new(:view_mode => 'search', :options => {:id => ''})
    @header_top_links_ext = w_class('header').new(:view_mode => 'top_links_ext')
    @header_top_links_int = w_class('header').new(:view_mode => 'top_links_int')
    @header_top_languages = w_class('header').new(:view_mode => 'top_languages')
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo = w_class('header').new(:view_mode => 'logo')
    @header_copyright = w_class('header').new(:view_mode => 'copyright')
    @static_tree = w_class('tree').new(:view_mode => 'static_ltr')
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')
    @meta_title = w_class('breadcrumbs').new(:view_mode => 'meta_title')
    #    @google_analytics = w_class('google_analytics').new
    @newsletter = w_class('newsletter').new(:view_mode => 'sidebar')
    @sitemap = w_class('sitemap').new
    @send_to_friend = w_class('send_to_friend').new
    @send_form = w_class('send_to_friend').new(:view_mode => 'form')
    @direct_link = w_class('shortcut').new
    @comments = w_class('comments').new
    @previous_comments = w_class('comments').new(:view_mode => 'previous')
    @sections = w_class('sections').new
    kabtv_resources
  end

  def render
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        title @meta_title
        meta(:name => 'description', :content => ext_description)
        javascript_include_tag 'flowplayer-3.2.4.min.js', 'flashembed.min.js', 'embed', 'jquery',
        'ui/ui.core.min.js', 'ui/jquery.color.js', 'ui/ui.tabs.min.js',
        'jquery.curvycorners.packed.js', 'jquery.browser.js',
        'jquery.media.js', 'jquery.metadata.js','jquery.form.js',
        '../highslide/highslide-full.js',
        'jq-helpers-hb',
        :cache => "cache_content_page-#{@presenter.website_hrid}"

        if presenter.node.can_edit?
          stylesheet_link_tag 'common/reset.css',
          '../ext/resources/css/ext-all',
          'rusmain/common.css',
          'rusmain/content_page.css',
          'rusmain/page_admin',
          'rusmain/jquery.tabs.css',
          'rusmain/superfish.css',
          '../highslide/highslide',
          'lightbox',
          :cache => false
          javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers',
          'ui/ui.sortable.min.js', 'ui/ui.draggable.min.js', 'ui/ui.droppable.min.js'
          javascript {
            rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
          }
        else
          stylesheet_link_tag 'common/reset.css',
          'rusmain/common.css',
          'rusmain/content_page.css',
          'rusmain/superfish.css',
          'rusmain/jquery.tabs.css',
          '../highslide/highslide',
          'lightbox'
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
            display @dynamic_tree
            div(:class => 'clear')
          }
          header_class = 'under-command-panel'
        end
        div(:id => 'header', :class => header_class){
          display @header_logo
          display @header_search
          div(:id => 'links'){
            make_sortable(:selector => '#header .links_ext', :axis => 'x') {
              display @header_top_links_ext
            }
            make_sortable(:selector => '#header .links_int', :axis => 'x') {
              display @header_top_links_int
            }
          }
          display @header_top_languages
        }
        div(:id => 'nav-empty'){
          nbsp
        }
        div(:id => 'nav'){
          div(:class => 'left-ear')
          div(:class => 'right-ear')

          display @sections
        }
        div(:id => 'body'){
          div(:id => 'body-left'){
            div(:class => 'side-box-top'){
              rawtext 'Kabbalah for Beginners'
              div(:class => 'left-ear')
              div(:class => 'right-ear')
            }
            div(:class => 'box-content'){
              display @static_tree
            }
            div(:class => 'side-box'){
              h3 'Newsletter'
              div(:class => 'box-content'){
                display @newsletter
              }
            }
            div(:class => 'side-box'){
              h3 'Updates'
              div(:class => 'box-content'){
                div(:class => 'update'){
                  h4 'Bold headline'
                  rawtext 'A few lines of text A few lines of text A few lines of text A few lines of text A few lines of text A few lines of text '
                  a(:href => ''){rawtext 'A link to something'}
                }
                hr
                div(:class => 'update'){
                  h4 'Bold headline'
                  rawtext 'A few lines of text A few lines of text A few lines of text A few lines of text A few lines of text A few lines of text '
                  a(:href => ''){rawtext 'A link to something'}
                }
              }
            }
          }
          div(:id => 'body-middle'){
            div(:class => 'mid-box-top'){
              display @titles
              div(:class => 'left-ear')
              div(:class => 'right-ear')
            }
            div(:id => 'content-header'){
              make_sortable(:selector => ".content-header", :axis => 'y') {
                display self.ext_content_header
              }
            }
            div(:id => 'mid-content'){
              display @breadcrumbs
              render_content_resource(@kabtv_node[0], :width => 378, :height => 288) unless @kabtv_node.empty?
              div(:class => 'bg'){
                div(:class => 'related') {
                  display self.ext_main_image
                  make_sortable(:selector => ".related", :axis => 'y') {
                    display self.ext_related_items
                  }
                }
                div(:class => 'content'){
                  make_sortable(:selector => "#mid-content .bg #content_resources", :axis => 'y') {
                    display self.ext_content
                  }
                }
                div(:class => 'services clear'){
                  display @direct_link
                  display @comments
                  display @send_to_friend
                  span(:class => 'clear')
                }

                display @send_form
                display @previous_comments
              }
            }
          }
          div(:class => 'clear')
        }
      }
      div(:id => 'footer'){
        display @sitemap
        make_sortable(:selector => '#footer .links', :axis => 'x') {
          display @header_bottom_links
        }
        display @header_copyright
      } unless ext_kabtv_exist

      rawtext '<script type="text/javascript"> setTimeout(function(){var a=document.createElement("script"); var b=document.getElementsByTagName("script")[0]; a.src=document.location.protocol+"//dnn506yrbagrg.cloudfront.net/pages/scripts/0021/4152.js?"+Math.floor(new Date().getTime()/3600000); a.async=true;a.type="text/javascript";b.parentNode.insertBefore(a,b)}, 1); </script>'

      #        display @google_analytics
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
    @kabtv_node ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['kabtv'],
      :depth => 1,
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

end
