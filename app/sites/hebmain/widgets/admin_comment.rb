class Hebmain::Widgets::AdminComment < WidgetManager::Base
  require 'parsedate'
  include ParseDate

  def render_full
    @presenter.disable_cache
    if tree_node.can_edit?
      create_main_div  
    end
  end
  
  def render_update_comment
    cm = Comment.find(@options['cid'])
    cm.update_attribute('title', @options['title'])
    cm.update_attribute('body', @options['body'])
    write_inside_of_form
  end
  
  def render_moderate_comment
#    if @options['filter'] == 'nil'
      action_hash= {'node_id' => @options['widget_node_id'], 'validate' => {}, 'delete' => []}
      @options.each{|op|
        is_action = op[0].include? "action"
        if is_action
          id = op[0].split('action')[1]
          action_value = op[1]
          case action_value 
          when 'validate' then 
            action_hash[action_value].store(id, {'is_valid' => '200'})
          when 'invalidate' then 
            action_hash['validate'].store(id, {'is_valid' => '500'})
          when 'delete' then
            action_hash[action_value].push(id)
          end
        end
      }
      Comment.delete(action_hash['delete'])
      Comment.update(action_hash['validate'].keys, action_hash['validate'].values )
      FileUtils.rm(Dir['tmp/cache/tree_nodes/'+@options['widget_node_id']+'-*']) rescue Errno::ENOENT
#    end
    write_inside_of_form
  end

  private 
  def create_main_div
    @presenter.disable_cache
    input :type=>"button", :value=>"Reload", 
      :onClick=>"window.location.href=window.location.href.split('?')[0]"
    br
    div(:class => 'admin_comment_main'){
      form(:id => 'admin_comment_form') {
        if params[:comment_id].blank?
          write_inside_of_form
        else
          single_comment(params[:comment_id])
        end
      }
    }
  end

  def write_inside_of_form
    p{
      input :type => 'submit', :name => 'Submit', :id => 'submit', :class => 'submit', :value => 'שלח'
      input :type => 'reset', :name => 'Cancel', :id => 'cancel', :class => 'submit', :value => 'בטל'
      input :type => 'hidden', :name => 'view_mode', :value => 'moderate_comment'
      input :type => 'hidden', :name => 'options[widget]', :value => 'admin_comment'
      input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id

#      select(:name => 'filter'){
#        option(:value => "nil"){text '------'}
#        option(:value => 'non-mod'){text 'Non Moderated'}
#      }

      
      b{'Admin comment'}
      table{
        thead{
          tr{
            th 'Page'
            th 'Date'
            th 'Valid'
            th 'Spam'
            th 'Name'
            th 'Title'
            th 'Body'
            th 'Edit'
            th(:colspan => '2'){text 'Valid'}
            th 'Del'
          }
        }

##        debugger
##        case @options['filter']
#        when 'nil' then comment_list = Comment.list_all_comments
#        when 'non-mod' then comment_list = Comment.list_all_non_moderated_comments
#        else
            comment_list = Comment.list_all_comments
#        end
        
        comment_list.each { |cl|
          cmcreated = parsedate cl.created_at.to_s  
          
          case cl.is_valid 
          when 0 then klass = 'notmod'
          when 500 then klass = 'badmod'
          else  klass = 'modok'
          end
          
          tr(:class => klass){
            td(:class => 'title'){a(:href => '/kabbalah/short/'+cl.node_id.to_s){text TreeNode.find(cl.node_id).resource.name}}
            td(:class => 'title'){ #date
              text cmcreated[2]
              text "."
              text cmcreated[1]
              text "."
              text cmcreated[0].to_s[2,3]
            }
            td(:class => 'valid'){text cl.is_valid}
            td(:class => 'spam'){text cl.is_spam}
            td(:class => 'title'){text cl.name}
            td(:class => 'title'){text cl.title}
            td(:class => 'body'){text cl.body}
            td(:class => 'funct'){
              a(:href => get_page_url(@presenter.node)+'?comment_id='+cl.id.to_s){text 'Edit'}
            }
            #valid
            td(:class => 'green'){
              input :type=>'radio', :name => 'options[action'+cl.id.to_s+']', :value => 'validate'
            }
            td(:class => 'red'){
              input :type=>'radio', :name => 'options[action'+cl.id.to_s+']', :value => 'invalidate'
            }
            td(:class => 'funct'){
              input :type=>'radio', :name => 'options[action'+cl.id.to_s+']', :value => 'delete'
            }
          }
        }
      }
    }
  end



  def single_comment(cid = 0)
    cm = Comment.find(cid)
    p(:class => 'right'){
      text _('Title')+': '
      input  :type => 'text', :name => 'options[title]', :value => cm.title
      br
      br
      text _('Body')+': '
      textarea(:cols => '10', :rows =>'15', :name => 'options[body]'){text cm.body}
      br
      br
      input :type => 'submit', :name => 'Submit', :id => 'submit', :class => 'submit', :value => 'שלח'
      input :type => 'button', :name => 'Cancel', :id => 'cancel', :class => 'submit',
      :onClick=>"$(this).replaceWith(\"<div id='loader'>&nbsp;&nbsp;<img class='tshuptshik' alt='Loading' src='/images/ajax-loader.gif'></div>\");window.location.href=window.location.href.split('?')[0]",
      :value => 'בטל'
      input :type => 'hidden', :name => 'view_mode', :value => 'update_comment'
      input :type => 'hidden', :name => 'options[cid]', :value => cid
      input :type => 'hidden', :name => 'options[widget]', :value => 'admin_comment'
      input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
    }
  end

 

end
