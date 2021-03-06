Blacklight.onLoad(function(){
  $('#orderable').nestable({maxDepth: 1, horizontalList: true, scroll: true});
  // visit the member's page when clicking anywhere on it
  $('.gallery li').bind('click', function(e) {
    anchor = $(this).find('a:not(.removeButton)')
    window.location.href = $(anchor).attr('href');
  });
  // prevent clicking on the remove checkbox from changing the page
  $('#orderable li .removeButton').bind('click', function(e){
    opacity = ($(this).find('input:checkbox').is(':checked') ? 0.5 : 1);
    $(this).closest('li').css('opacity', opacity);
    e.stopPropagation();
  });
  updateWeights($('#orderable'));
});

function updateWeights(selector) {
  $.each(selector, function() {
    $(this).on('change', function(event){
      // Scope to a container because we may have two orderable sections on the page (e.g. About page has pages and contacts)
      container = $(event.currentTarget);
      var data = $(this).nestable('serialize')
      var weight = 0;
      for(var i in data) {
        var node_id = data[i]['id'];
        node = findNode(node_id, container);
        setWeight(node, weight++);
      }
    });
  });
}

function findNode(id, container) {
  return container.find("[data-id=\""+id+"\"]");
}

function setWeight(node, weight) {
  weight_field(node).val(weight);
}

/* find the input element with data-property="weight" that is nested under the given node */
function weight_field(node) {
  return find_property(node, "weight");
}

function find_property(node, property) {
  return node.find("input[data-property=" + property + "]");
}
