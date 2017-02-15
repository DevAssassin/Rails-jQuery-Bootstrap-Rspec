module CounselorsHelper
  def counselor_form(institution, counselor, &block)
    if counselor.new_record?
      semantic_form_for(counselor, :url => institution_counselors_url(institution), &block)
    else
      semantic_form_for(counselor, :url => institution_counselor_url(institution, counselor), &block)
    end
  end
end
