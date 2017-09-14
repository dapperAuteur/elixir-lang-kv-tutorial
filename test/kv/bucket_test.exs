defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do # this is the callback that wasn't in the previous version of the test
    {:ok, bucket} = start_supervised(KV.Bucket)
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    # `bucket` is now the bucket from the setup block
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  @tag :mine
  @tag capture_log: true

  test "deletes `key` from `bucket`, if `key` exists", %{bucket: bucket} do

    assert KV.Bucket.get(bucket, "leche") == nil

    KV.Bucket.put(bucket, "leche", 4)
    assert KV.Bucket.get(bucket, "leche") == 4

    KV.Bucket.delete(bucket, "leche")

    assert KV.Bucket.get(bucket, "leche") == nil
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end

# this version doesn't use callbacks
# defmodule KV.BucketTest do
#   use ExUnit.Case, async: true
#
#   test "stores values by key" do
#     {:ok, bucket} = start_supervised KV.Bucket
#     assert KV.Bucket.get(bucket, "milk") == nil
#
#     KV.Bucket.put(bucket, "milk", 3)
#     assert KV.Bucket.get(bucket, "milk") == 3
#   end
# end
