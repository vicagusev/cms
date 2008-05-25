class Hebmain::Widgets::Header < WidgetManager::Base
  
  def render_top_links
    div(:class => 'search') do
      img(:src => img_path('search.gif'), :alt => 'Search')
      input(:name => 'search')
    end
    ul(:class => 'links') do      
      top_links.each do |e|
        li do
          w_class('link').new(:tree_node => e, :view_mode => 'with_image').render_to(self)
        end
      end
    end
  end
  
  def render_logo
    div(:class => 'logo') do
      h1 'קבלה לעם'
      img(:src => img_path('logo.gif'), :alt => 'Title')
    end
  end
  
  private
  
  def top_links
    TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['link'], 
      :depth => 1,
      # :placeholder => 'top_links',
      :has_url => false
    )               
  end    
  def bottom_links
    TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['link'], 
      :depth => 1,
      # :placeholder => 'bottom_links',
      :has_url => false
    )               
  end    
end
