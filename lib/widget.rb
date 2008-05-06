module WidgetManager

  class Base < Erector::Widget
    include WidgetExtensions # additional helpers
        
    attr_accessor :presenter, :tree_node, :resource, :view_mode
    
    def initialize(*args, &block)
      super(*args, &block)
      @presenter = Thread.current[:presenter]
      args_hash = args.detect{|arg|arg.is_a?(Hash) && arg.has_key?(:tree_node)} || {}
      @tree_node = args_hash[:tree_node] rescue nil
      @view_mode = args_hash[:view_mode] || 'full'
      
    end
    
    def render
      render_method = 'render_' + view_mode
      # debugger
      self.send(render_method) if self.respond_to?(render_method)
    end

    
    def resource
      @resource ||= tree_node.resource rescue nil
    end
    
    
  end
  
  class Template < Base
    
    attr_reader :layout
    
    def initialize(*args, &block)
      super(*args, &block)
      # debugger
      args_hash = args.detect{|arg|
        arg.is_a?(Hash) && (arg.has_key?(:tree_node) || arg.has_key?(:layout_class))
        } || {}
      @tree_node ||= presenter.node rescue nil
      layout_class = args_hash[:layout_class] || nil
      @layout = layout_class.new
      
    end
    def render
      set_layout
      layout.render_to(doc)
    end
  end

  class Layout < Base

  end       

end