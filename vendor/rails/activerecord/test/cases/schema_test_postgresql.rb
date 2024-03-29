# -*- encoding : utf-8 -*-
require "cases/helper"

class SchemaTest < ActiveRecord::TestCase
  self.use_transactional_fixtures = false

  SCHEMA_NAME = 'test_schema'
  SCHEMA2_NAME = 'test_schema2'
  TABLE_NAME = 'things'
  INDEX_A_NAME = 'a_index_things_on_name'
  INDEX_B_NAME = 'b_index_things_on_different_columns_in_each_schema'
  INDEX_A_COLUMN = 'name'
  INDEX_B_COLUMN_S1 = 'email'
  INDEX_B_COLUMN_S2 = 'moment'
  COLUMNS = [
    'id integer',
    'name character varying(50)',
    'email character varying(50)',
    'moment timestamp without time zone default now()'
  ]

  def setup
    @connection = ActiveRecord::Base.connection
    @connection.execute "CREATE SCHEMA #{SCHEMA_NAME} CREATE TABLE #{TABLE_NAME} (#{COLUMNS.join(',')})"
    @connection.execute "CREATE SCHEMA #{SCHEMA2_NAME} CREATE TABLE #{TABLE_NAME} (#{COLUMNS.join(',')})"
    @connection.execute "CREATE INDEX #{INDEX_A_NAME} ON #{SCHEMA_NAME}.#{TABLE_NAME}  USING btree (#{INDEX_A_COLUMN});"
    @connection.execute "CREATE INDEX #{INDEX_A_NAME} ON #{SCHEMA2_NAME}.#{TABLE_NAME}  USING btree (#{INDEX_A_COLUMN});"
    @connection.execute "CREATE INDEX #{INDEX_B_NAME} ON #{SCHEMA_NAME}.#{TABLE_NAME}  USING btree (#{INDEX_B_COLUMN_S1});"
    @connection.execute "CREATE INDEX #{INDEX_B_NAME} ON #{SCHEMA2_NAME}.#{TABLE_NAME}  USING btree (#{INDEX_B_COLUMN_S2});"
  end

  def teardown
    @connection.execute "DROP SCHEMA #{SCHEMA2_NAME} CASCADE"
    @connection.execute "DROP SCHEMA #{SCHEMA_NAME} CASCADE"
  end

  def test_with_schema_prefixed_table_name
    assert_nothing_raised do
      assert_equal COLUMNS, columns("#{SCHEMA_NAME}.#{TABLE_NAME}")
    end
  end

  def test_with_schema_search_path
    assert_nothing_raised do
      with_schema_search_path(SCHEMA_NAME) do
        assert_equal COLUMNS, columns(TABLE_NAME)
      end
    end
  end

  def test_raise_on_unquoted_schema_name
    assert_raise(ActiveRecord::StatementInvalid) do
      with_schema_search_path '$user,public'
    end
  end

  def test_without_schema_search_path
    assert_raise(ActiveRecord::StatementInvalid) { columns(TABLE_NAME) }
  end

  def test_ignore_nil_schema_search_path
    assert_nothing_raised { with_schema_search_path nil }
  end

  def test_dump_indexes_for_schema_one
    do_dump_index_tests_for_schema(SCHEMA_NAME, INDEX_A_COLUMN, INDEX_B_COLUMN_S1)
  end

  def test_dump_indexes_for_schema_two
    do_dump_index_tests_for_schema(SCHEMA2_NAME, INDEX_A_COLUMN, INDEX_B_COLUMN_S2)
  end

  private
    def columns(table_name)
      @connection.send(:column_definitions, table_name).map do |name, type, default|
        "#{name} #{type}" + (default ? " default #{default}" : '')
      end
    end

    def with_schema_search_path(schema_search_path)
      @connection.schema_search_path = schema_search_path
      yield if block_given?
    ensure
      @connection.schema_search_path = "'$user', public"
    end

    def do_dump_index_tests_for_schema(this_schema_name, first_index_column_name, second_index_column_name)
      with_schema_search_path(this_schema_name) do
        indexes = @connection.indexes(TABLE_NAME).sort_by {|i| i.name}
        assert_equal 2,indexes.size

        do_dump_index_assertions_for_one_index(indexes[0], INDEX_A_NAME, first_index_column_name)
        do_dump_index_assertions_for_one_index(indexes[1], INDEX_B_NAME, second_index_column_name)
      end
    end

    def do_dump_index_assertions_for_one_index(this_index, this_index_name, this_index_column)
      assert_equal TABLE_NAME, this_index.table
      assert_equal 1, this_index.columns.size
      assert_equal this_index_column, this_index.columns[0]
      assert_equal this_index_name, this_index.name
    end
end
