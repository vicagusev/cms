class Mainsites::Widgets::Streamer < WidgetManager::Base

  def render_full
    w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(self)
  end

end
