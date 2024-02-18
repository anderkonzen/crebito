defmodule Crebito.KVTest do
  use ExUnit.Case, async: true

  alias Crebito.KV

  setup do
    kv = start_supervised!(KV)
    %{kv: kv}
  end

  test "returns false when id is not stored", %{kv: kv} do
    refute KV.has?(kv, 1)
  end

  test "returns true when id is stored", %{kv: kv} do
    assert :ok == KV.put(kv, 1)
    assert KV.has?(kv, 1)
  end
end
