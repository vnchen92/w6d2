require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @column if @column
    column_names = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @column = column_names.first.map{|key| key.to_sym}
  end

  def self.finalize!
    self.columns.each do |column|
      define_method("#{column}") do
        self.attributes[column]
      end
    end

    self.columns.each do |column|
      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    everything = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    self.parse_all(everything)
  end

  def self.parse_all(results)
    results.map do |value|
      self.new(value)
    end
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
      params.each do |attr_name, value|
        if self.class.columns.include?(attr_name.to_sym)
          self.send("#{attr_name.to_sym}=", value)
        else
          raise "unknown attribute '#{attr_name}'"
        end
      end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
