class RecruitBoard
  include Mongoid::Document
  add_indexes

  field :name, :type => String
  field :description, :type => String
  field :recruit_ids, :type => Array

  referenced_in :program, index: true

  def recruit_list=(list_of_ids)
    recruits = list_of_ids.keep_if {|id| BSON::ObjectId.legal?(id.to_s) }.map {|id| Recruit.find(id)}
    self.recruit_ids = recruits.map {|recruit| recruit.id}
  end

  # TODO: refactor this
  def recruits
    (recruit_ids || []).map do |id|
      begin
        Recruit.find(id) if BSON::ObjectId.legal?(id.to_s)
      rescue Exception => exec
        #logger = Logger.new("#{Rails.root}/log/my.log")
        #logger.info exec
      end

    end
  end

  def push_recruit(recruit)
    self.recruit_ids ||= []
    self.recruit_ids << recruit.id unless self.recruit_ids.include? recruit.id or !BSON::ObjectId.legal?(recruit.id.to_s)
  end

  def remove_recruit(recruit)
    recruit_ids && self.recruit_ids.delete(recruit.id)
  end
end
