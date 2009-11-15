class Global::Widgets::Video < WidgetManager::Base

  def video_admin  
    w_class('cms_actions').new( :tree_node => tree_node, 
      :options => {:buttons => %W{ edit_button delete_button }, 
        :resource_types => %W{ site_updates_entry },
        :new_text => _(:create_new_content_item),
        :has_url => false
      }).render_to(self)
  end

  def render_homepage_gallery
    video_admin
    href = get_flash_url
    title = get_title
    a(:href => href, :onclick => "javascript:urchinTracker('/homepage/widget/video_gallery/#{title}')"){text title}
  end

  def render_homepage_one_video
    "'#{get_flash_url}'"
  end

  def render_full
    video_admin
    # flowplayer
    # default flash, second wmv url 

    show_title = get_show_title
    if show_title.nil?
      show_title = false
    end
    
    if (show_title)
      h3(:class => 'video'){
        text get_title
      }
    end
    div(:class => 'full-video') {
      id = tree_node.object_id
      if (show_title)
        description = get_description
        p { rawtext description } unless description.empty?
      end

      autoplay = get_autoplay
      autoplay = autoplay.kind_of?(String) ? true : autoplay
      image = get_image
      if image && !image.empty? and !autoplay
        image = "{url:'#{image}',autoPlay:true},"
      else
        image = ''
      end
      div(:id => "flashplayer-#{id}", :style => 'height:378px;width:504px;'){}
      javascript {
        #                  logo: {
        #                    url: '/images/hebmain/logo-flv.png',
        #                    fullscreenOnly: false,
        #                    top:2,
        #                    right:2,
        #                    opacity: 0.4
        #                  },
        rawtext <<-Embedjs
          $(document).ready(function() {
               flowplayer('flashplayer-#{id}','/flowplayer/flowplayer.commercial-3.1.5.swf',{
                  key:'#\@932a7f91ab5747d7f90',
                  clip:{
                    scaling: 'scale',

                    // track start event for this clip
                    onStart: function(clip) {
                        _tracker._trackEvent("Videos", "Play", clip.url);
                    },

                    // track pause event for this clip. time (in seconds) is also tracked
                    onPause: function(clip) {
                        _tracker._trackEvent("Videos", "Pause", clip.url, parseInt(this.getTime()));
                    },

                    // track stop event for this clip. time is also tracked
                    onStop: function(clip) {
                        _tracker._trackEvent("Videos", "Stop", clip.url, parseInt(this.getTime()));
                    },

                    // track finish event for this clip
                    onFinish: function(clip) {
                        _tracker._trackEvent("Videos", "Finish", clip.url);
                    }
                  },
                  playlist:[
                    #{image}
                    {url:'#{get_flash_url}',autoPlay: #{autoplay.to_s}}

                  ],
                  // show stop button so we can see stop events too
                  plugins: {
                      controls: {
                          stop: true
                      }
                  }
               });
        });
        Embedjs
      }
    }
    
    div(:class => 'embed'){
      wmvpath = get_download_link
      unless wmvpath.empty?
        span(:class => 'services'){
          a(:href => wmvpath, :title => 'download', :target => "_blank") {
            img(:src => '/images/download.gif', :alt => 'download')
            text _(:download)
          }
        }
      end
    }
  end
  
  def render_video_list
    video_admin
    href = get_flash_url
    a(:href => href, :class => 'h1-img') {
      img(:src => get_image(:image_name => 'thumb'), :alt => '', :class => 'flashplayer')
    }
    a(:href => href, :class => 'h1-play') {
      text get_title
    }
    div(:class => 'descr-play') {text get_description}
    div(:class => 'clear')
  end
end


#object="id = "MediaPlayer", width = '180', height = '200',
#    classid = "CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95",
#    codebase = "http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=5,1,52,701",
#    standby = "Loading MicrosoftÂ® WindowsÂ® Media Player components...",
#    type = "application/x-oleobject", :align => "middle") {
#      param(:name => "FileName", :value => get_url)
#      param(:name => "ShowStatusBar", :value => 'true')
#      param(:name => "DefaultFrame", :value => 'mainframe')
#      param(:name => "autostart", :value => 'false')
#      embed(:type => "application/x-mplayer2",
#      pluginspage = "http://www.microsoft.com/Windows/MediaPlayer/",
#      src = get_url,
#      autostart = "false",
#      align = "middle",
#      width = "176",
#      height = "144",
#      defaultframe = "rightFrame",
#      showstatusbar = "true") {}"
# 
