class Hebmain::Layouts::ContentPage < WidgetManager::Layout

  attr_accessor :ext_content, :ext_breadcrumbs, :ext_content_header, :ext_title, :ext_description,
                :ext_main_image, :ext_related_items, :ext_kabtv_exist,
                :ext_abc_up, :ext_abc_down, :ext_keywords

  def initialize(*args, &block)
    super

    @header_top_links    = w_class('header').new(:view_mode => 'top_links')
    @header_bottom_links = w_class('header').new(:view_mode => 'bottom_links')
    @header_logo         = w_class('header').new(:view_mode => 'logo')
    @header_copyright    = w_class('header').new(:view_mode => 'copyright')
    @static_tree         = w_class('tree').new(:view_mode => 'static')
    @dynamic_tree        = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @meta_title          = w_class('breadcrumbs').new(:view_mode => 'meta_title')
    @google_analytics    = w_class('google_analytics').new
    @newsletter          = w_class('newsletter').new(:view_mode => 'sidebar')
    @sitemap             = w_class('sitemap').new
    @send_to_friend      = w_class('send_to_friend').new
    @direct_link         = w_class('shortcut').new
    @subscription        = w_class('header').new(:view_mode => 'subscription')
    @comments            = w_class('comments').new
    @archive             = w_class('archive').new
    @previous_comments   = w_class('comments').new(:view_mode => 'previous')
    @share               = w_class('share_this').new(:view_mode => 'hebrew')
    @languages           = w_class('language_menu').new
  end

  def is_langing_page?
    false
  end

  def render
    if is_langing_page?
      render_langing_page
    else
      render_regular
    end
  end

  def render_head
    head {
      meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
      meta "http-equiv" => "Content-language", "content" => "utf8"
      meta(:name => 'node_id', :content => @tree_node.id)
      meta(:name => 'description', :content => ext_description)
      meta(:name => 'keywords', :content => ext_keywords)
      meta :name => 'viewport', :content => 'width=device-width, initial-scale=1'

      title @meta_title
      text ext_abc_up

      javascript_include_tag 'flowplayer-3.2.4.min.js', 'flashembed.min.js'
      javascript_include_tag 'embed', 'jquery',
                             'pikabu.js',
                             'ui/ui.core.min.js', 'ui/jquery.color.js', 'ui/ui.tabs.min.js',
                             'jquery.curvycorners.packed.js', 'jquery.browser.js',
                             'jquery.media.js', 'jquery.metadata.js', 'jquery.form.js',
                             '../highslide/highslide-full.js', 'countdown',
                             'jq-helpers-hb' #,
      #:cache => "cache_content_page-#{@presenter.website_hrid}"

      javascript_include_tag 'wpaudioplayer/audio-player.js'
      #javascript_include_tag '/lightbox/js/lightbox'

      stylesheet_link_tag 'reset-fonts-grids',
                          'base-min',
                          'hebmain/common',
                          'hebmain/header',
                          'hebmain/inner_page',
                          'hebmain/jquery.tabs.css',
                          'hebmain/widgets',
                          '../highslide/highslide',
                          'lightbox',
                          :cache => "cache_content_page-#{@presenter.website_hrid}",
                          :media => 'all'
      #stylesheet_link_tag '/lightbox/css/lightbox'
      stylesheet_link_tag 'hebmain/print', :media => 'print'
      site_config = $config_manager.site_settings(@presenter.website.hrid)
      site_name   = site_config[:site_name]
      stylesheet_link_tag "#{site_name}/#{site_name}"

      #        if presenter.node.can_edit?
      perm = AuthenticationModel.get_max_permission_to_child_tree_nodes_by_user_one_level(presenter.node.id)
      if presenter.node.can_edit? || perm >= 2 # STUPID, but there are no constatns yet...!!!
        stylesheet_link_tag 'hebmain/page_admin', '../ext/resources/css/ext-all'
        javascript_include_tag '../ext/adapter/ext/ext-base', '../ext/ext-all', 'ext-helpers',
                               'ui/ui.sortable.min.js', 'ui/ui.draggable.min.js', 'ui/ui.droppable.min.js',
                               :cache => "cache_content_page_admin-#{@presenter.website_hrid}"
        javascript {
          rawtext 'Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";'
          rawtext 'Ext.onReady(function(){Ext.QuickTips.init()});'
        }
      end

      rawtext "\n<!--[if IE 6]>\n"
      stylesheet_link_tag 'hebmain/ie6', :media => 'all'
      stylesheet_link_tag 'hebmain/ie6_print', :media => 'print'
      rawtext "\n<![endif]-->\n"

      rawtext "\n<!--[if IE 7]>\n"
      stylesheet_link_tag 'hebmain/ie6', :media => 'all'
      stylesheet_link_tag 'hebmain/ie7', :media => 'all'
      rawtext "\n<![endif]-->\n"

      rawtext "\n<!--[if IE 8]>\n"
      stylesheet_link_tag 'hebmain/ie8', :media => 'all'
      rawtext "\n<![endif]-->\n"

      rawtext <<-FB
	<script>(function() {
	  var _fbq = window._fbq || (window._fbq = []);
	  if (!_fbq.loaded) {
	    var fbds = document.createElement('script');
	    fbds.async = true;
	    fbds.src = '//connect.facebook.net/en_US/fbds.js';
	    var s = document.getElementsByTagName('script')[0];
	    s.parentNode.insertBefore(fbds, s);
	    _fbq.loaded = true;
	  }
	  _fbq.push(['addPixelId', '682077405245448']);
	})();
	window._fbq = window._fbq || [];
	window._fbq.push(['track', 'PixelInitialized', {}]);
	</script>
<noscript><img height="1" width="1" alt="" style="display:none" src="https://www.facebook.com/tr?id=682077405245448&amp;ev=PixelInitialized" /></noscript>
      FB

      stylesheet_link_tag 'pikabu', :media => 'all'
      # stylesheet_link_tag 'pikabu-theme', :media => 'all'
      stylesheet_link_tag 'hebmain/responsive', :media => 'all'

      rawtext <<-GA_new
        <script type="text/javascript">
                    (function(i, s, o, g, r, a, m) { i['GoogleAnalyticsObject']=r; i[r]=i[r]||function() {
                      (i[r].q=i[r].q||[]).push(arguments) }, i[r].l=1*new Date(); a=s.createElement(o),
                        m=s.getElementsByTagName(o)[0]; a.async=1; a.src=g; m.parentNode.insertBefore(a, m)
                    })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');

        ga('create', 'UA-54667616-1', 'auto');
        ga('send', 'pageview');
        ga('require', 'displayfeatures');
        setTimeout("ga('send', 'event', 'read', '15_sec')", 15000);
        </script>
      GA_new

      if site_config[:googleAdd][:use]
        rawtext <<-GCA
            <script type="text/javascript" src="http://partner.googleadservices.com/gampad/google_service.js"></script>
            <script type="text/javascript">
                    GS_googleAddAdSenseService("#{site_config[:googleAdd][:googleAddAdSenseService]}");
                    GS_googleEnableAllServices();
            </script>
            <script type="text/javascript">
                    GA_googleAddSlot("#{site_config[:googleAdd][:googleAddAdSenseService]}", "#{site_config[:googleAdd][:slot]}");
            </script>
            <script type="text/javascript">
                    GA_googleFetchAds();
            </script>
        GCA
      end
      rawtext <<-GCAC
            <!-- Google Code for Cmapus-AUGSEP-2012 -->
            <!-- Remarketing tags may not be associated with personally identifiable information or placed on pages related to sensitive categories. For instructions on adding this tag and more information on the above requirements, read the setup guide: google.com/ads/remarketingsetup -->
            <script type="text/javascript">
            /* <![CDATA[ */
              var google_conversion_id = 1061981111;
              var google_conversion_label = "DQGzCNXRigMQt5ey-gM";
              var google_custom_params = window.google_tag_params;
              var google_remarketing_only = true;
            /* ]]> */
            </script>
            <script type="text/javascript" src="//www.googleadservices.com/pagead/conversion.js"></script>
            <noscript>
              <div style="display:inline;">
                <img height="1" width="1" style="border-style:none;" alt="" src="//googleads.g.doubleclick.net/pagead/viewthroughconversion/1061981111/?value=0&amp;label=DQGzCNXRigMQt5ey-gM&amp;guid=ON&amp;script=0"/>
              </div>
            </noscript>
      GCAC
    }
    rawtext @styles if @styles
    rawtext '<script type="text/javascript"> setTimeout(function(){var a=document.createElement("script"); var b=document.getElementsByTagName("script")[0]; a.src=document.location.protocol+"//dnn506yrbagrg.cloudfront.net/pages/scripts/0021/4152.js?"+Math.floor(new Date().getTime()/3600000); a.async=true;a.type="text/javascript";b.parentNode.insertBefore(a,b)}, 1); </script>'

  end

  def render_langing_page
    site_config = $config_manager.site_settings(@presenter.website.hrid)

    @styles = "
      <style>
        #bd {background:0 none;}
      </style>
    ";
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      render_head
      div(:id => 'doc', :class => 'yui-t7') {
        div(:id => 'bd') {
          if site_config[:googleAdd][:use]
            rawtext <<-GCA
              <script type="text/javascript">
                GA_googleFillSlot("#{site_config[:googleAdd][:slot]}");
              </script>
            GCA
          end
          div(:class => 'yui-g') {
            div(:class => 'content') {
              make_sortable(:selector => ".content", :axis => 'y') {
                self.ext_content.render_to(self)
              }
            }
          }
        }
      }
    }
  end

  def render_regular
    site_config = $config_manager.site_settings(@presenter.website.hrid)
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en", :id => "#{site_config[:site_name]}") {
      render_head
      body {
        @dynamic_tree.render_to(self)

        div(:class => "m-pikabu-viewport") {
          div(:class => "m-pikabu-sidebar m-pikabu-left") {
            h2 {
              rawtext 'Left Sidebar Content'
            }
          }
          div(:class => "m-pikabu-container") {
            div(:class => 'mobile-header mobile-only') {
              a(:class => "m-pikabu-nav-toggle", :'data-role' => "left", :'href' => "javascript:;") {
              }
              a(:href => presenter.home, :class => 'mobile-logo'){img(:src => img_path('m-logo.svg'), :alt => _(:kabbalah_la_am), :title => _(:kabbalah_la_am))}
              a(:class => "m-pikabu-nav-toggle", :'data-role' => "right", :'href' => "javascript:;") {
              }
            }
            div {
              render_body(site_config)
            }
          }

          div(:class => "m-pikabu-sidebar m-pikabu-right") {
            h2 {
              rawtext 'Right Sidebar Content'
            }
          }
        }
      }
    }
  end

  def render_body(site_config)
    div(:id => 'bg_wrap') {
    }
    div(:id => 'doc2', :class => 'yui-t4') {
      div(:id => 'bd') {
        p(:class => 'notice') { rawtext flash[:notice] } if flash[:notice]
        if site_config[:googleAdd][:use]
          div(:id => 'google_ads') {
            rawtext '
              <script type="text/javascript">
                GA_googleFillSlot("kab-co-il_top-banner_950x65");
              </script>
            '
          }
        end
        div(:id => 'yui-main') {
          div(:class => 'yui-b') {
            div(:class => 'yui-ge') {
              div(:id => 'hd', :class => 'mobile-hidden') {
                make_sortable(:selector => '#hd .links', :axis => 'x') {
                  @header_top_links.render_to(self)
                }
              }
              div(:class => 'menu mobile-hidden') {
                w_class('sections').new.render_to(self)
              }
              div(:class => 'margin-25 mobile-hidden') { text ' ' }
              self.ext_breadcrumbs.render_to(self)
              div(:class => 'content-header') {
                make_sortable(:selector => ".content-header", :axis => 'y') {
                  self.ext_content_header.render_to(self)
                }
              }
              div(:class => 'yui-u first') {
                div(:class => 'content') {
                  make_sortable(:selector => ".content", :axis => 'y') {
                    self.ext_content.render_to(self)
                  }
                  @subscription.render_to(self)
                  div(:class => 'clear')
                  @share.render_to(self)
                  @comments.render_to(self)
                  @send_to_friend.render_to(self)
                  @direct_link.render_to(self)
                  @archive.render_to(self) if archived_resources.size > 0 && !@presenter.page_params.has_key?('archive')
                  @previous_comments.render_to(self)
                }
              }
              div(:class => 'yui-u') {
                div(:class => 'related') {
                  self.ext_main_image.render_to(self)
                  make_sortable(:selector => ".related", :axis => 'y') {
                    self.ext_related_items.render_to(self)
                  }
                }
              }
            }
          }
        }
        div(:class => 'yui-b mobile-hidden') {
          div(:id => 'hd-r') {
            @header_logo.render_to(self)
            @languages.render_to(self)
          } #Logo goes here
          div(:class => 'nav') {
            div(:class => 'h1') {
              text presenter.main_section.resource.name if presenter.main_section
              div(:class => 'h1-right')
              div(:class => 'h1-left')
            }
            @static_tree.render_to(self)
          }

          @newsletter.render_to(self)

          global_site_updates.each { |e|
            render_content_resource(e)
          }
        }
      }

      div(:id => 'ft') {
        @sitemap.render_to(self) unless ext_kabtv_exist
        make_sortable(:selector => '#ft .links', :axis => 'x') {
          @header_bottom_links.render_to(self)
        }
        @header_copyright.render_to(self)
      }
    }
    text ext_abc_down
    @google_analytics.render_to(self)
  end

  private

  def right_column_resources
    @tree_nodes ||= TreeNode.get_subtree(
        :parent              => tree_node.id,
        :resource_type_hrids => ['site_updates'],
        :depth               => 1,
        :placeholders        => ['right']
    )
  end

  def global_site_updates
    @site_updates ||= TreeNode.get_subtree(
        :parent              => presenter.website_node.id,
        :resource_type_hrids => ['site_updates', 'banner'],
        :depth               => 1,
        :placeholders        => ['right']
    )
  end

  def archived_resources
    @archived_resources ||= TreeNode.get_subtree(
        :parent              => tree_node.id,
        :resource_type_hrids => ['content_page'],
        :depth               => 1,
        :has_url             => true,
        :status              => ['ARCHIVED']
    )
  end
end
