
module DB
  class Connection
    def initialize
      options = { dbname: 'site_crawler', user: 'site_crawler' }
      @connection = PG.connect(options)

      @pg_encoder = PG::TextEncoder::Array.new name: "String[]", delimiter: ','
      @pg_decoder = PG::TextDecoder::Array.new name: "String[]", delimiter: ','
    end

    def create_table_resources
      create_table_query = <<-create_query
        create table IF NOT EXISTS resources (
          id          serial     PRIMARY KEY,
          url         text       UNIQUE NOT NULL,
          params_list text[]            NOT NULL,
          created_at  TIMESTAMP        without time zone default (now() at time zone 'utc'),
          updated_at  TIMESTAMP        without time zone default (now() at time zone 'utc')
        )
      create_query
      @connection.exec(create_table_query)
    end

    def query sql
      res = @connection.exec( sql )
      fields = res.fields
      values = res.values
      values.map do |row|
        _hash = {}
        row.each_with_index do |r, ind|
          _hash.merge!({fields[ind]=> r})
        end
        _hash
      end
    end

    def query_resources
      col_types = get_column_types 'resources'
      col_types_hash = {}
      col_types.map do |row|
        col_types_hash.merge!({row['column_name']=> row['data_type']})
      end

      result = []
      query("SELECT * FROM resources").each do |row|
        _hash = {}
        row.each do |col_name, col_value|
          if col_types_hash[col_name] == "ARRAY"
            _hash.merge!({col_name=> cast(col_value)})
          else
            _hash.merge!({col_name=> col_value})
          end
        end
        result << _hash
      end
      result
    end

    def get_column_types table_name
      data_type_query = <<-data_type
        SELECT
         column_name, data_type
        FROM
         information_schema.COLUMNS
        WHERE
         TABLE_NAME = '#{table_name}';
      data_type

      query data_type_query
    end

    def cast(value)
      if value.is_a?(::String)
        value = begin
          @pg_decoder.decode(value)
        rescue TypeError
          # malformed array string is treated as [], will raise in PG 2.0 gem
          # this keeps a consistent implementation
          []
        end
      end
    end

    class << self
      def create_connection
        new
      end
    end
  end
end
