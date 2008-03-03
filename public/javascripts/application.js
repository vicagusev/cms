// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function mark_for_destroy(element) {
  if (confirm('This operation will delete this element from all the resources. Are you sure?')){
		$(element).next('.should_destroy').value = 1;
		$(element).up('.dynamic_element').hide();
  }
}

// Make sure the behaviors still work even after navigating to another page using the ajax navigation.
Event.addBehavior.reassignAfterAjax = true;

// Behaviors
Event.addBehavior({

'#show_all_websites:change' : function() {
	if($F(this) != null) {
		$('website_id').hide();
	}
	else {
		$('website_id').show();
	}
},
/*This will update the hidden input field (in resource editing) which holds the actual value 
	to be passed to the model as the checkbox value*/
'input.property_checkbox:change' : function() {
	if($F(this) != null) {
		this.next().value = 't';
	}
	else {
		this.next().value = 'f';
	}
},
'#property_field_type:change' : function() {
	switch($F(this)) {
	case 'List':
		$('property_list_id').enable();
		new Effect.Appear('list_container');
		$('property_geometry').disable();
		new Effect.Fade('file_container');
		break;
	case 'File':
		$('property_geometry').enable();
		new Effect.Appear('file_container');
		$('property_list_id').disable();
		new Effect.Fade('list_container');
		break;
	default:
		$('property_geometry').disable();
        $('property_list_id').disable();
		new Effect.Fade('file_container');
		new Effect.Fade('list_container');
	}
}
});