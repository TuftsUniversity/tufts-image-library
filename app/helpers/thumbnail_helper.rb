module ThumbnailHelper
  # works with SolrDocuments and ActiveFedora models
  def thumbnail_tag(document, image_options={})
    if is_a(document, TuftsImage)
      image_tag download_path(document.id, datastream_id: 'Thumbnail.png')
    elsif is_a(document, CuratedCollection)
      image_tag '/assets/folder_thumbnail.png'
    else
      content_tag :span, '', class: 'canonical-image'
    end
  end

  private

  # Checks to see if this SolrDocument or model inherits from a given class
  def is_a(document, klass)
    if document.is_a? SolrDocument
      document['active_fedora_model_ssi'].constantize.ancestors.include? klass
    else
      document.is_a? klass
    end
  end
end
