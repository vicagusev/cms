class Mainsites::Widgets::Sitemap < WidgetManager::Base

  skip_page_map

  def render_full
    div(:class => 'sitemap mobile-hidden'){
      div(:class => 'sitemap-inner'){

        presenter.main_sections.each {|section|

          sub_sections = get_sub_section(section) || []
          ul(:class => 'box'){
            li {
              a section.resource.name, :href => get_page_url(section), :class => 'title'
              ul{
                sub_sections.each {|section|
                  li(:class => 'list'){
                    a(:href => get_page_url(section)){text section.resource.name}
                  }
                }
              }
            }
          } unless sub_sections.empty?
        }
        div(:class => 'clear')
      }
    }
  end

  private

  def get_sub_section (tree_node)
    TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['content_page',],
      :depth => 1,
      :has_url => true,
      :properties => 'b_hide_on_navigation = false')

  end

end
