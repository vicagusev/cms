class Resource < ActiveRecord::Base

  has_and_belongs_to_many :websites
  belongs_to :resource_type
  accepts_nested_attributes_for :resource_type

  has_many :resource_properties, :order => 'position ASC', :dependent => :destroy, :include => :property
  has_many :rp_number_properties, :class_name => 'RpNumber', :dependent => :destroy
  has_many :rp_string_properties, :class_name => 'RpString', :dependent => :destroy
  has_many :rp_text_properties, :class_name => 'RpText', :dependent => :destroy
  has_many :rp_plaintext_properties, :class_name => 'RpPlaintext', :dependent => :destroy
  has_many :rp_timestamp_properties, :class_name => 'RpTimestamp', :dependent => :destroy
  has_many :rp_date_properties, :class_name => 'RpDate', :dependent => :destroy
  has_many :rp_boolean_properties, :class_name => 'RpBoolean', :dependent => :destroy
  has_many :rp_file_properties, :class_name => 'RpFile', :dependent => :destroy
  has_many :rp_list_properties, :class_name => 'RpList', :dependent => :destroy

  accepts_nested_attributes_for :resource_properties
  accepts_nested_attributes_for :rp_number_properties
  accepts_nested_attributes_for :rp_string_properties
  accepts_nested_attributes_for :rp_text_properties
  accepts_nested_attributes_for :rp_plaintext_properties
  accepts_nested_attributes_for :rp_timestamp_properties
  accepts_nested_attributes_for :rp_date_properties
  accepts_nested_attributes_for :rp_boolean_properties
  accepts_nested_attributes_for :rp_file_properties
  accepts_nested_attributes_for :rp_list_properties

  has_many :tree_nodes, :dependent => :destroy do
    def main
      find :first, :conditions => 'is_main = true'
    end
  end
  accepts_nested_attributes_for :tree_nodes

  attr_accessor :tree_node
  attr_accessor :slang

  #only associate resources of the type 'website'
  has_one :website, :foreign_key => 'entry_point_id'

#  after_update :save_resource_properties, :update_tree_node
  after_update :update_tree_node
  after_create :create_tree_node
  before_destroy :nullify_website_if_exists

  # Let each property of the Resource to validate itself
  validates_associated :resource_properties

  # validate :required_properties_present
  validate :uniqueness_of_permalink

  def name
    name_code_calc = eval calculate_name_code(resource_type.name_code)
    un_escape_string_for_code name_code_calc
  end

  # Used in the new/edit of a resource, when creating the form
  def get_resource_properties
    result = []
    resource_type.properties.each do |property|

      elements = eval("rp_#{property.field_type.downcase}_properties") || []
      elements = elements.select{ |rp| rp.property_id == property.id } unless elements.empty?
      if elements.empty?
        new_element = eval "Rp#{property.field_type.camelize}.new"
        new_element.resource = self
        new_element.property = property
        elements << new_element
      end
      elements.each do |rp|
        rp.resource = self
        rp.property = property
      end
      result += elements
    end
    result
  end

  # Used in the new/edit of a resource, when creating the form
  def get_empty_resource_properties
    return [] if resource_type == nil

    result = []
    resource_type.properties.each do |property|

      elements = eval("rp_#{property.field_type.downcase}_properties") || []
      elements = elements.select{ |rp| rp.property_id == property.id } unless elements.empty?
      if elements.empty?
        new_element = eval "Rp#{property.field_type.camelize}.new"
        new_element.resource = self
        new_element.property = property
        elements << new_element
        result += elements
      end
    end
    result
  end

  # Old Version - now using: get_resource_properties function instead (Saved for anycase) 
  def get_resource_property_by_property(property) 
    resource_property_array = eval("rp_#{property.field_type.downcase}_properties") || []
              
    if new_record? #new or not validated new
      if resource_property_array.empty? #new before validation
        rp = eval "Rp#{property.field_type.camelize}.new"
        rp.property = property
      else #not valid new
        rp = resource_property_array.detect { |e| e.property_id == property.id }
        rp.resource = self
        rp.property = property
      end
    else #edit or not validated edit
      rp = resource_properties.detect { |e| e.property_id == property.id }
      if rp.nil?
        rp = resource_property_array.detect { |e| e.property_id == property.id } || (eval "Rp#{property.field_type.camelize}.new")
        rp.resource = self
        rp.property = property
      end
    end
    return rp
  end
  
  # convenient access to the properties of the resource
  def properties(property = nil)
    if property
      result = resource_properties.select{|rp| rp.property.hrid == property} rescue nil
      case result.size
      when 0
        nil
      when 1
        result[0]
      else
        result
      end
    else
      resource_properties
    end
  end

  #if the resource has link tree_nodes
  def has_links?
    link_count = TreeNode.count_by_sql("Select count(*) from tree_nodes where is_main <> true and resource_id = #{id}")
    return (link_count > 0)
  end
  
  protected

  def nullify_website_if_exists
    if website && resource_type_id == Website.get_website_resource_type.id
      website.nullify_website_resource
    end
  end

  # We cannot call this directly in property, because we don't know there resource_type
  def required_properties_present
    result = false
    resource_properties.each do |rp|
      result ||= rp.is_required(resource_type)
    end
    if result
      # There was error on one of fields, so we need to invalidate all resource
      # Otherwise it will pass validation :(
      errors.add(:base, "There are required fields without values")
    end
  end

  def has_permalink?
    tree_node && tree_node.has_key?(:permalink)
  end

  def uniqueness_of_permalink
    return unless has_permalink?
    permalink = tree_node[:permalink] = TreeNode.permalink_escape(tree_node[:permalink])
    parent_id = tree_node[:parent_id]
    tree_node_id = tree_node[:id]

    errors.add(:permalink, " -- must be supplied") if permalink.empty?

    my_website = TreeNode.find_first_parent_of_type_website(parent_id)
    return unless my_website
    has_error = false         
    TreeNode.get_subtree(:parent => my_website.id).reject { |tmp| tmp.id == tree_node_id.to_i } .select { |child|
      if child.permalink.eql?(permalink)
        has_error = true
      end 
    }
    if has_error
      errors.add(:permalink, " -- must be unique (#{permalink})")
    end
  end

  def get_resource_property_by_property_hrid(hrid)
    begin
      property = resource_type.properties.find_by_hrid(hrid)
      return escape_string_for_code(get_resource_property_by_property(property).get_value)
    rescue
      ''
    end
  end

  def calculate_name_code(name_code)
    name_code.gsub(/<([^>]*?)>/) do |match|
      "'#{get_resource_property_by_property_hrid($1)}'"
    end
  end
  # These two functions will prevent errors when using \" or \' chars in property which is set as the 'name' attribute
  def escape_string_for_code(s)
    s.to_s.gsub(/\"/, "\&quot;").gsub(/\'/, "\&#39;").gsub(/\\/, "\&#92;")
  end  

  def un_escape_string_for_code(s)
    s.to_s.gsub(/\&quot;/, "\"").gsub(/\&#39;/, "\'")
  end  

  def update_tree_node
    if tree_node
      node = TreeNode.find_by_id(tree_node[:id])
      id = tree_node.delete(:id)
      node.update_attributes(tree_node)
      tree_node.merge!({:id => id})
    end
  end

  # Creates tree node if the resource was created with hierarchy
  def create_tree_node
    if tree_node
      new_node = TreeNode.new(tree_node)
      new_node.resource = self
      new_node.save!
    end
  end
end
