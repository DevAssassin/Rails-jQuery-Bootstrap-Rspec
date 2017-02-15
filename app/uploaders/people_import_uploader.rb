# encoding: utf-8

class PeopleImportUploader < CarrierWave::Uploader::Base

  def s3_access_policy
    :private
  end

  def store_dir
    "imports/person/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w{csv}
  end

end
