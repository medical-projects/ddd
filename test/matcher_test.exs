defmodule MatcherTest do
  use ExUnit.Case

  @fb "foo/bar.behaviour"
  @empty %{}
  @full %{ "diagnosis" =>  [ %{ "name" => "CAP" }, %{ "name" => "GORD" } ] }
  @_ :action

  test "Match on sample behaviour" do
    success = Ddd.Matcher.process_block("behaviours/sample/sample.behaviour", @_, {@empty, @full})
    assert(success == true)
  end

  test "basic match for is" do
    pre = %{}
    post = %{ "key" => "friday"}

    {ok, _} = Ddd.Matcher.process_line(@fb, ~s(when "key" is "friday"), {@_, pre, post})
    assert(ok == :ok)

    {ok, _} = Ddd.Matcher.process_line(@fb, ~s(when "key" is "wednesday"), {@_, pre, post})
    assert(ok == :fail)
  end

  test "basic match for is not" do
    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" is not "healthy"), {@_, @empty, @full}
    assert ok == :ok

    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" is not "CAP"), {@_, @empty, @full}
    assert ok == :fail
  end

  test "basic match for was" do
    pre = %{ "key" => "friday"}
    post = %{}

    {ok, _} = Ddd.Matcher.process_line(@fb, ~s(when "key" was "friday"), {@_, pre, post})
    assert(ok == :ok)

    {ok, _} = Ddd.Matcher.process_line(@fb, ~s(when "key" was "wednesday"), {@_, pre, post})
    assert(ok == :fail)
  end

  test "basic match for was not" do
    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" was not "healthy"), {@_, @full, @empty}
    assert ok == :ok

    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" was not "CAP"), {@_, @full, @empty}
    assert ok == :fail
  end

  test "basic match for is/was case of atom" do
    pre = %{ "key"=> "friday"}
    post = %{ "key"=> "friday"}

    {ok, _} = Ddd.Matcher.process_line(@fb, ~s(When "key" was "friday"), {@_, pre, post})
    assert(ok == :ok)

    {ok, _} = Ddd.Matcher.process_line(@fb, ~s(When "key" was "wednesday"), {@_, pre, post})
    assert(ok == :fail)
  end

  test "basic match for did contain" do
    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" did contain "ord"), {@_, @full, @empty}
    assert ok == :ok

    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" did contain "death"), {@_, @full, @empty}
    assert ok == :fail
  end

  test "basic match for contains" do
    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" contains "ord"), {@_, @empty, @full}
    assert ok == :ok

    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" contains "death"), {@_, @empty, @full}
    assert ok == :fail
  end

  test "basic match for did not contain" do
    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" did not contain "death"), {@_, @full, @empty}
    assert ok == :ok

    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" did not contain "ord"), {@_, @full, @empty}
    assert ok == :fail
  end


  test "basic match for does not contain" do
    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" does not contain "death"), {@_, @empty, @full}
    assert ok == :ok

    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" does not contain "ord"), {@_, @empty, @full}
    assert ok == :fail
  end

  test "basic match for changed to" do
    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" changed to "CAP"), {@_, @empty, @full}
    assert ok == :ok

    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When "diagnosis.name" changed to "healthy"), {@_, @empty, @full}
    assert ok == :fail
  end

  test "basic match for admitted to" do
    ward8 = %{ "location" => [ %{ "ward" => "Ward 8"} ] }

    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When admitted to "Ward 8"), {:admit, @empty, ward8}
    assert ok == :ok

    {ok, _} = Ddd.Matcher.process_line @fb, ~s(When admitted to "Ward 10"), {:admit, @empty, ward8}
    assert ok == :fail
  end

  test "rule count" do
    # Not an actual test yet, but helpful for me to work with.
    attribs = Ddd.Matcher.Step.__info__(:attributes)
    rules = for {:rules, r} <- attribs, do: r
    assert length(rules) > 0
  end
end
