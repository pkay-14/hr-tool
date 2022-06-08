Mongoid.load!(Rails.root.to_s+"/config/mongoid.yml")
Mongoid::History.tracker_class_name = :history_tracker
Mongoid::Config.belongs_to_required_by_default = false
