class SqlQuery < ActiveRecord::Base
  #@hosts
  #@pathegens
  #@locations
  def self.create user_id, params
      @sql_query = SqlQuery.new
      @sql_query.users_id =user_id
      @sql_query.query_string= "SELECT * FROM gisbank.isolates where 1=1"

    return @sql_query
  end

  def get_sequences
    return find_by_sql(query_string)

  end

end
