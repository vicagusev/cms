module WidgetExtensions

  @@sort_prefix_no = 0

  def img_path(image_name)
    "#{domain}/images/#{presenter.site_name}/#{image_name}"
  end                  
  
  def w_class(name)
    presenter.w_class(name) rescue nil
  end
  
  # can pass optional :image_name => 'my_custom_name' to get a specific filtered image
  def get_file_html_url(args_hash)
    attachment = args_hash[:attachment]
    image_name = args_hash.has_key?(:image_name) ? args_hash[:image_name] : 'myself'
    get_file_url(attachment, image_name) if attachment
  end

  def get_page_url(tree_node, options = {})
    args = {:prefix => presenter.controller.website.prefix, :id => tree_node.permalink}
    unless options.empty?
      ags.merge!({:options => options})
    end
    domain + tm_path(args)
  end

  def get_css_url(style_name)
    domain + css_path(:website_id => presenter.controller.website.id, :css_id => style_name)  
  end

  def get_css_external_url(style_name)
    style_name + '.css'
  end

  #  def get_json_url
  #    domain + json_path  
  #  end

  # this is used to generate URL in development mode
  def port
    @port ||= presenter.port
  end

  def domain
    @full_domain ||= presenter.domain
  end

  def get_file_url(attachment, image_name = 'myself')
    my_domain = domain.sub('http://','')
    format = File.extname(attachment.filename).delete('.')
    image_url(:image_id => ((attachment.id % 100).to_s) , 
      :image_name => attachment.id.to_s + "_" + image_name,
      :format => format, 
      :host => my_domain)
  end
  
  def add_node_link_to_resource(parent_node, resource, placeholder = '')
    new_tree_node = 
      TreeNode.new(
      :parent_id => parent_node.id,
      :has_url => false,
      :placeholder => placeholder,
      :is_main => false
    )
    new_tree_node.resource = resource
    new_tree_node.save!
  end

  def remove_link_from_resource(tree_node)
    if !tree_node.is_main && tree_node.can_delete?
      tree_node.max_user_permission = nil
      tree_node.destroy
    end
  end
  
  def show_content_resources(options, &block)
    options.delete(:resources).each_with_index { |e, idx|
      block.call(idx) if block
      klass = e.resource.status == 'DRAFT' ? ' draft' : ''
      
      div(:id => sort_id(e), :class => klass) {
        sort_handle if options[:sortable]
        render_content_resource(e, options)
      }
    }
  end
  
  def render_content_resource(tree_node, options = nil)
    return unless tree_node
    class_name = tree_node.resource.resource_type.hrid
    if options.is_a?(Hash)
      options.merge!(:widget => class_name.to_sym)
      view_mode = calculate_view_mode(options)
    else
      view_mode = options || 'full'
    end
    w_class(class_name).new(@helpers, :tree_node => tree_node, 
      :view_mode => view_mode).render_to(self)
  end

  def calculate_view_mode(options)
    return 'full' unless options
    return options[:force_mode] if options.include?(:force_mode)
    view_modes = @presenter.site_settings[:view_modes]
    return 'full' unless view_modes
    parent = view_modes[options[:parent]]
    return 'full' unless parent
    placeholder = parent[options[:placeholder]]
    return 'full' unless placeholder
    placeholder[options[:widget]] || 'full'
  end

  def sort_handle
    img(:class => 'handle', :src => "/images/draggable.png", :alt => "") if tree_node.can_edit?
  end
  
  def sort_id(item)
    @@sort_prefix_no += 1
    "el#{@@sort_prefix_no}_#{item.position}"
  end
  
  def make_sortable(options, &block)
    unless tree_node.can_edit?
      block.call if block
      return
    end
    
    selector = options[:selector]
    if options.include?(:direction) # :vertical, :horizontal
      direction = options[:direction]
      constraint = "horizontal" if direction == :horizontal
      constraint = "vertical" if direction == :vertical
    elsif options.include?(:constraint)
      constraint = options[:constraint] # "vertical", "horizontal"
    else
      constraint = options[:axis] # :axis => "x|y"
    end

    sortable_element(selector, :scroll => true, :handle => 'handle',
      :opacity => 0.5,
      :ghosting => true, :dropOnEmpty => true, :cursor => '"move"',
      :url => {:controller => 'sites/templates',
        :action => :update_positions,
        :id => "0",
        :key => selector,
        :nodes => YAML.dump(block.call.map { |node| {:id => node.id} })
      },
      :expression => 'el[0-9]+[-=_](.+)',
      :constraint => constraint,
      :success => mark_success(selector),
      :error => alert(selector)
    )
    javascript {
      rawtext "jQuery('#{selector} .handle').mouseover(function(event){"
      rawtext '  $(event.target).parent().toggleClass("sort-area"); '
      rawtext '}).mouseout(function(event){'
      rawtext '  $(event.target).parent().toggleClass("sort-area"); '
      rawtext '});'
    }
  end

  def alert(selector)
    javascript = highlight(selector, "red", "white");
    javascript << "alert(request.responseText);"
  end

  def mark_success(selector)
    highlight(selector)
  end
  
  def highlight(element, start_color = "#ffff99", end_color = "#ffffff")
    javascript = "jQuery('#{element}').animate({backgroundColor:'#{start_color}'}, 500)"
    javascript << ".animate({backgroundColor:'#{end_color}'}, 500);"
  end

end