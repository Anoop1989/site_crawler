class ModelBase
  class << self
    def find_by params={}
      puts "find_by: #{table_name}"
    end

    def table_name
      raise "table_name undefined"
    end
  end
end
