class Hebmain::Widgets::Header < WidgetManager::Base
  
  def render_top_links
    
    search_page = domain + '/' + presenter.controller.website.prefix + '/' + 'search'
        
    form(:action => search_page, :id => 'cse-search-box'){
      div(:class => 'search'){
        input :type => 'image',:src => img_path('search.gif'), :name => 'sa', :class => 'submit'
        input :type => 'hidden', :name => 'cx', :value => '011301558357120452512:ulicov2mspu'
        input :type => 'hidden', :name => 'ie', :value => 'UTF-8'
        input :type => 'hidden', :name => 'cof', :value => 'FORID:11'
        input :type => 'text', :name => 'q', :size => '31', :class => 'text'
      }
      rawtext <<-CODE
        <script type="text/javascript" src="http://www.google.com/coop/cse/brand?form=cse-search-box&amp;lang=he"></script>
      CODE
    }   
  
    ul(:class => 'links') {
      w_class('cms_actions').new(:tree_node => presenter.website_node, :options => {:buttons => %W{ new_button }, :resource_types => %W{ link },:new_text => 'לינק חדש', :has_url => false, :placeholder => 'top_links'}).render_to(self)
      top_links.each { |e|
        li(:id => sort_id(e)) {
          sort_handle
          w_class('link').new(:tree_node => e, :view_mode => 'with_image').render_to(self)
        }
      }
    }

    top_links

  end

  def render_bottom_links
    w_class('cms_actions').new(:tree_node => presenter.website_node, 
      :options => {:buttons => %W{ new_button }, 
        :resource_types => %W{ link },:new_text => 'לינק חדש לפוטר', 
        :has_url => false, 
        :placeholder => 'bottom_links'
      }).render_to(self)
    ul(:class => 'links') {
      bottom_links.each_with_index { |e, i|
        li {rawtext '|'} unless i.eql?(0)
        li(:id => sort_id(e)) {
          sort_handle
          w_class('link').new(:tree_node => e).render_to(self)
        }
      }
    }
    bottom_links

  end
  
  def render_logo
    div(:class => 'logo') do
      h1 'קבלה לעם'
      a(:href => presenter.home){img(:src => img_path('logo.png'), :alt => 'Title')}
    end
  end
  
  def render_copyright
    e = copyright
    # Set the updatable div  - THIS DIV MUST BE AROUND THE CONTENT TO BE UPDATED.
    updatable = 'up-' + presenter.website_node.id.to_s
    div(:id => updatable){

      if e.nil?
        w_class('cms_actions').new(:tree_node => presenter.website_node, 
          :options => {:buttons => %W{ new_button }, 
            :resource_types => %W{ copyright },
            :new_text => 'צור יחידת זכויות יוצרים', 
            :button_text => 'הוספת זכויות יוצרים',
            :has_url => false
          }).render_to(self)

      else
        w_class('copyright').new(:tree_node => e).render_to(self)
      end
    }
  end
  
  private
  
  def top_links
    @top_links ||= 
      TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['link'], 
      :depth => 1,
      :placeholders => 'top_links',
      :has_url => false
    )               
  end    
  def bottom_links
    @bottom_links ||=
      TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['link'], 
      :depth => 1,
      :placeholders => 'bottom_links',
      :has_url => false
    )               
  end    
  def copyright
    @copyright ||=
      TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['copyright'], 
      :depth => 1,
      :has_url => false
    ) 
    @copyright.empty? ? nil : @copyright.first
  end    
end
