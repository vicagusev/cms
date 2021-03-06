class AddHideBreadcrumbsToContentPage < ActiveRecord::Migration
  def self.up
    migration_login

    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    raise 'Failed to find content_page resource type' unless resource_type

    property = Property.new(
      :name => 'Hide Breadcrumbs',
      :field_type => 'Boolean',
      :hrid => 'hide_breadcrumbs',
      :resource_type_id => resource_type.id,
      :is_required => false)
    raise 'Failed to create property \'Hide Breadcrumbs\'' unless property
    property.save!

  end

  def self.down
    migration_login
    
    resource_type = ResourceType.find(:first, :conditions => {:hrid => 'content_page'})
    return unless resource_type

    property = Property.find(:first, :conditions => {:hrid => 'hide_breadcrumbs', :resource_type_id => resource_type.id})
    return unless property
    resource_properties = ResourceProperty.find(:all, :conditions => {:property_id => property.id})
    resource_properties.each{ |rp| rp.delete }
    property.delete
  end
end
