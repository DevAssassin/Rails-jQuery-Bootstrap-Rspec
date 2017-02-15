class ProfileAttachment
  include Mongoid::Document
  add_indexes

  embedded_in :person, :inverse_of => :attachments
  mount_uploader :attachment, ProfileAttachmentUploader, :mount_on => :attachment_filename

  validates_presence_of :attachment

end
