require "authentication_model"

class TreeNode < ActiveRecord::Base
  belongs_to :resource
  has_many :tree_node_ac_rights, :dependent => :destroy
  acts_as_tree :order => "position"
  acts_as_list
  
  attr_accessor :has_url
  attr_accessor :ac_type
  
  #attribute_method_suffix '_changed?'
  
   def can_edit?
    @ac_type >= 2
  end
  
  def can_criate_child?
    @ac_type >= 2
  end
  
  def can_read?
    @ac_type != 0 #"Forbidden"
  end
  
  #can logical delete (change status to deleted)
  def can_delete?
    if (3 <= get_min_permission_to_child_tree_nodes_by_user())
      return true
    else
      return false
    end
  end
  
  #can delete in DB (destroy)
  def can_administrate? 
    if (4 <= get_min_permission_to_child_tree_nodes_by_user())
        return true
    end 
    return false
  end
 
  # The has_url virtual variable is passed to when requesting for resource edit/create
  # if true than on the resource edit/create of this tree_node will show permalink text field
  # Embedded resources won't have permalink
  def has_url
    if self.new_record?
      ActiveRecord::ConnectionAdapters::Column.value_to_boolean(@has_url)
    else
      not permalink.blank?
    end
  end
  
  def after_find
    #set max access type by current user
    self.ac_type ||= AuthenticationModel.get_ac_type_to_tree_node(self.id)
  end 
  
  def after_save
    #copy parent permission to the new tree_node
    AuthenticationModel.copy_parent_tree_node_permission(self)
  end

  def self.get_subtree(parent = 0, depth = 0)
    find_by_sql "SELECT  a.* FROM  connectby('tree_nodes', 'id', 'parent_id', 'position',  '#{parent}', #{depth}) 
    AS t(id int, parent_id int, level integer, position int) 
    join tree_nodes a on (a.id = t.id) ORDER BY  t.position"
  end

   def before_destroy
    #check if has permission for destroy action
    if not can_edit?
      logger.error("User #{AuthenticationModel.current_user} has not permission " + 
          "for edit tree_node: #{id} resource: #{resource_id}")
      raise "User #{AuthenticationModel.current_user} has not permission " + 
          "for destroy tree_node: #{id} resource: #{resource_id}"
    end
  end
  
  def before_save
    #check if has permission for edit action
    if not can_administrate?
      logger.error("User #{AuthenticationModel.current_user} has not permission " + 
          "for edit tree_node: #{id} resource: #{resource_id}")
      raise "User #{AuthenticationModel.current_user} has not permission " + 
          "for edit tree_node: #{id} resource: #{resource_id}"
    end
  end
  
  def after_destroy
    #delete resource if exist
    #used for recurcive delete of tree_nodes
    resource.destroy if resource
  end
  
  class << self
    alias :old_find_by_sql :find_by_sql
  
  def find_by_sql(arg)
    output=self.old_find_by_sql(arg)
    output.delete_if {|x| x.ac_type == 0 }
    output
  end
  
  def find_as_admin(tree_node_id)
    res = old_find_by_sql "select * from tree_nodes where id=#{tree_node_id}"
    if res.length == 1
      return res[0]
    end
    nil
  end
end
   #return min permission to child nodes by current user (recursive)
  def get_min_permission_to_child_tree_nodes_by_user()
    if AuthenticationModel.current_user_is_admin?
      return 4 #"Administrating"
    end
    result = ac_type
    
    #optimization (if it already minimal value)
    if result == 0 #"Forbidden"
      return result 
    end
    
    chields =  TreeNode.old_find_by_sql("Select * from tree_nodes 
        where parent_id =#{id}")
    chields.each{ |tn|
        #get current node permission
        if tn.ac_type < result
          result = tn.ac_type
        end
        
        #optimization (if it already minimal value)
        if result == 0 #"Forbidden"
          return result 
        end
        #get child permission
        tmp_res = tn.get_min_permission_to_child_tree_nodes_by_user()
        if tmp_res < result
          result = tmp_res
        end
    }
    result
  end
  
  #ExtJS tree service methods
  def self.root_nodes
    find(:all, :conditions => ["parent_id = ?", 0], :order => "position ASC")
  end

  def self.find_children(start_id = nil)
    start_id.to_i == 0 ? root_nodes : find(start_id).children
  end

  def leaf
    if children.length == 0
      true
    else
      false
    end
  end

  def to_json_with_leaf(options = {})
    self.to_json_without_leaf(options.merge(:methods => :leaf))
  end
  alias_method_chain :to_json, :leaf
  
  protected
  
  def TreeNode.find_first_parent_of_type_website(parent_id)
    node = TreeNode.find(:first, :conditions => ["parent_id = ?", parent_id])
    while node && !node.resource.resource_type.hrid.eql?('website')
      node = node.parent 
    end
    node
  end
  
     
  #def attribute_changed?(attr)
  #      
  #end
  end
