require 'cases/helper'
require 'models/teapot'

class BasicInclusionModelTest < ActiveRecord::TestCase
  def test_basic_model
    Teapot.create!(:name => "Ronnie Kemper")
    assert_equal "Ronnie Kemper", Teapot.first.name
  end

  def test_initialization
    t = Teapot.new(:name => "Bob")
    assert_equal "Bob", t.name
  end

  def test_inherited_model
    teapot = CoolTeapot.create!(:name => "Bob")
    teapot.reload

    assert_equal "Bob", teapot.name
    assert_equal "mmm", teapot.aaahhh
  end

  def test_generated_feature_methods
    assert Teapot < Teapot::GeneratedFeatureMethods
  end

  def test_exists
    t = Teapot.create!(:name => "Ronnie Kemper")
    assert Teapot.exists?(t)
  end

  def test_predicate_builder
    t = Teapot.create!(:name => "Bob")
    assert_equal "Bob", Teapot.where(:id => [t]).first.name
    assert_equal "Bob", Teapot.where(:id => t).first.name
  end

  def test_nested_model
    assert_equal "ceiling_teapots", Ceiling::Teapot.table_name
  end
end

class InclusionUnitTest < ActiveRecord::TestCase
  def setup
    @klass = Class.new { include ActiveRecord::Model }
  end

  def test_non_abstract_class
    assert !@klass.abstract_class?
  end

  def test_abstract_class
    @klass.abstract_class = true
    assert @klass.abstract_class?
  end

  def test_establish_connection
    assert @klass.respond_to?(:establish_connection)
    assert ActiveRecord::Model.respond_to?(:establish_connection)
  end

  def test_adapter_connection
    name = "#{ActiveRecord::Base.connection_config[:adapter]}_connection"
    assert @klass.respond_to?(name)
    assert ActiveRecord::Model.respond_to?(name)
  end

  def test_connection_handler
    assert_equal ActiveRecord::Base.connection_handler, @klass.connection_handler
  end

  def test_mirrored_configuration
    ActiveRecord::Base.time_zone_aware_attributes = true
    assert @klass.time_zone_aware_attributes
    ActiveRecord::Base.time_zone_aware_attributes = false
    assert !@klass.time_zone_aware_attributes
  ensure
    ActiveRecord::Base.time_zone_aware_attributes = false
  end

  # Doesn't really test anything, but this is here to ensure warnings don't occur
  def test_included_twice
    @klass.send :include, ActiveRecord::Model
  end
end

class InclusionFixturesTest < ActiveRecord::TestCase
  fixtures :teapots

  def test_fixtured_record
    assert_equal "Bob", teapots(:bob).name
  end

  def test_timestamped_fixture
    assert_not_nil teapots(:bob).created_at
  end
end
