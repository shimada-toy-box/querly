require_relative "test_helper"

class ConfigTest < Minitest::Test
  Config = Querly::Config
  Preprocessor = Querly::Preprocessor

  def test_load_taggings
    config = Config.new
    config.load_taggings({ "tagging" => [
      { "path" => "test", "tags" => "test" },
      { "path" => "test/models", "tags" => "test model" },
      { "path" => "app/models", "tags" => ["rails model", "ruby"] },
      { "path" => "db", "tags" => ["ignored"] }
    ]})

    # Longger pattern first, shorter pattern last
    assert_equal ["test/models", "app/models", "test", "db"], config.taggings.map(&:path_pattern)

    # Tagging object contains array of set of tags
    assert_equal [Set.new(["test", "model"])], config.taggings[0].tags_set
    assert_equal [Set.new(["rails", "model"]), Set.new(["ruby"])], config.taggings[1].tags_set
    assert_equal [Set.new(["test"])], config.taggings[2].tags_set
    assert_equal [Set.new(["ignored"])], config.taggings[3].tags_set
  end

  def test_load_rules
    config = Config.new
    config.load_rules({ "rules" => [
      {
        "id" => "test1",
        "pattern" => "foo",
        "message" => "message1"
      },
      {
        "id" => "test2",
        "pattern" => "foo.bar",
        "message" => "message2",
        "tags" => "foo"
      },
      {
        "id" => "test3",
        "pattern" => "foo.bar.baz",
        "message" => "message3",
        "tags" => ["foo", "bar"]
      }
    ]})

    # Load tags
    assert_equal Set.new(), config.rules[0].tags
    assert_equal Set.new(["foo"]), config.rules[1].tags
    assert_equal Set.new(["foo", "bar"]), config.rules[2].tags
  end

  def test_load_preprocessors
    config = Config.new
    config.load_preprocessors({
                                ".haml" => "haml -I lib -r foo_plugin",
                                ".slim" => "slim"
                              })

    haml_preprocessor = config.preprocessors[".haml"]
    assert_instance_of Preprocessor, haml_preprocessor
    assert_equal ".haml", haml_preprocessor.ext
    assert_equal "haml -I lib -r foo_plugin", haml_preprocessor.command

    slim_preprocessor = config.preprocessors[".slim"]
    assert_instance_of Preprocessor, slim_preprocessor
    assert_equal ".slim", slim_preprocessor.ext
    assert_equal "slim", slim_preprocessor.command
  end
end