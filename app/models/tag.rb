class Tag
  include Mongoid::Document

  field :name
  field :category
  field :number_of_uses, type: Integer, default: 0

  has_and_belongs_to_many :projects

  index name: 1

  scope :category, -> (c) { where(category: c).order(name: :asc) }
  scope :popular, -> { order(number_of_uses: :desc).limit(7) }
  scope :sorted, -> { order name: :asc }

  CATEGORY_LIST = %w( technology year domain )

  CATEGORY_LIST.each do |c_name|
    define_method("#{c_name}?".to_sym) { category == c_name }
  end

  def self.format
    tags_str = self.all.map(&:name).join(', ')
    if tags_str.length <= 30
      tags_str
    else
      tags_str[0, 25] + '...'
    end
  end

  def use!
    inc(number_of_uses: 1)
  end

end
