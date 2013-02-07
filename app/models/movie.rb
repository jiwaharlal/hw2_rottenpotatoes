class Movie < ActiveRecord::Base
  def self.availableRatings
    result = Set.new
    all.each do |m|
      result.add(m.rating)
    end
    return result
  end
end
