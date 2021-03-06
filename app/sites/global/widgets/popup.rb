class Global::Widgets::Popup < WidgetManager::Base

  def render_full
    w_class('cms_actions').new(:tree_node => @tree_node,
                               :options => {:buttons => %W{ edit_button delete_button },
                                            :mode => 'inline',
                                            :resource_types => %W{ popup }}).render_to(self)

    image = get_picture(:image_name => 'original')
    style = image ? "background: url('#{image}') no-repeat 0 0; width: 165px; height: 40px; border: 0 none; color: transparent; cursor: pointer;" : ''
    center = @tree_node.placeholder == 'main_content' ? 'highslide-center' : ''

    div (:class => center) {
      button(:class => "highslide-button", :style => style, :onclick => "hs.minHeight = 400; return hs.htmlExpand(this, { contentId: 'my-content-#{id}' } )") {
        rawtext get_button_text
      }
    }

    javascript {
      rawtext <<-JS
function validate_and_submit(id) {
  $('.alert').html('&nbsp;');

  if (#{get_confirm_required} == true) {
    if (!$('#my-content-' + id + ' #agree').is(':checked')) {
      $('.alert').html("עליך להסכים: #{get_confirm_text}");
      return false;
    }
  }

  if ($('#my-content-' + id + ' #YMP0').val() == '') {
    $('.alert').html("נא למלא שדה #{get_subscriber_name}");
    return false;
  }

  var email = $('#my-content-' + id + ' #YMP2').val();

  if (email == '') {
    $('.alert').html("נא למלא שדה #{get_email}");
    return false;
  }

  if (!validateEmail(email)) {
    $('.alert').html("אימייל לא תקין");
    return false;
  }

  return true;
}
      JS
    }

    div(:class => "highslide-html-content", :id => "my-content-#{id}") {
      div(:class => "highslide-header", :style => "height: 12px;") {
        ul {
          li(:class => "highslide-move") {
            a(:onclick => "return false", :title => "Move", :href => "#") {
              span { rawtext 'Move' }
            }
          }
          li(:class => "highslide-close") {
            a(:onclick => "return hs.close(this)", :title => "סגור (esc)", :href => "#") {
              span { rawtext 'Close' }
            }
          }
        }
      }

      div(:class => "highslide-body", :style => 'text-align: right;') {

        div(:style => 'font-size: 20px; margin-top: -10px;') {
          rawtext get_title
        } unless get_title.empty?

        div(:class => 'alert') {
          rawtext '&nbsp;'
        }

        rawtext get_text_on_page

        form(:class => 'inner', :action => new_home_mail_path, :method => "post", :onsubmit => "javacript:google_tracker('/homepage/widget/popup/new_building');") {
          input :type => 'hidden', :name => 'ymlp', :value => get_ymlp

          div {
            label(:for => "YMP0") {
              input :type => 'text', :id => "YMP0", :name => 'YMP0', :value => ''
              rawtext get_subscriber_name
            }
          }

          div {
            label(:for => "YMP2") {
              input :type => 'text', :id => "YMP2", :name => 'YMP2', :value => ''
              rawtext get_email
            }
          }

          div(:class => 'textarea') {
            rawtext get_free_text
            textarea :id => "free_text", :name => 'free_text', :value => ''
          } if get_free_text_required

          div(:style => 'clear: both; padding-top: 10px;') {
            rawtext get_confirm_text
            input :type => 'checkbox', :id => "agree", :name => 'agree', :value => 'subscribe', :checked => 'checked'
          } unless get_confirm_text.empty?

          div(:class => 'text', :style => 'float: right; margin-top: 5px;') {
            a(:href => get_direct_link_url, :target => '_blank') {
              rawtext get_direct_link_text
            }
          } unless get_direct_link_url.empty?

          div {
            box_text_button = get_submit_text.empty? ? 'שלח' : get_submit_text
            input :name => "subscribe", :class => "button highslide-button", :value => box_text_button, :type => "submit", :title => box_text_button, :alt => box_text_button, :onclick => "return validate_and_submit(#{id});"
          }
        }

        div(:class => "clb") { rawtext '&nbsp;' }
      }

      div(:class => 'highslide-footer') {
        span(:class => "highslide-resize", :style => "float: right; cursor: se-resize;")
      }

      div(:class => 'clb')
    }

    # Bait Hadash <bait2bb@gmail.com>
  end

end
