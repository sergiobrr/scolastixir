defmodule Portal.Cache.CacheSupervisor do
  @moduledoc """
  This is the dynamic supervisor for the portal
  cache worker. It restart the cache process if it fails or
  terminate unexpectedly
"""
  use DynamicSupervisor
  alias Portal.Cache.CacheWorker

  def start_link([]) do
    DynamicSupervisor.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def init(_) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_children: 100
    )
  end

  def put(id, content) when is_binary(id) and is_bitstring(content) do
    case find_cache(id) do
      nil -> start_worker(id, content)
      pid -> {:ok, pid}
    end
  end

  def get(id) when is_binary(id) do
    case find_cache(id) do
      nil -> {:error, :not_found}
      pid -> CacheWorker.get_content(pid)
    end
  end

  def refresh(id) when is_binary(id) do
    case find_cache(id) do
      nil -> {:error, :not_found}
      pid -> CacheWorker.refresh(pid)
    end
  end

  defp start_worker(id, content) when is_binary(id) and is_bitstring(content) do
    DynamicSupervisor.start_child(
      __MODULE__,
      cache_worker_spec(id, content)
    )
  end

  defp find_cache(id) when is_binary(id) do
    GenServer.whereis(CacheWorker.name_for(id))
  end

  defp cache_worker_spec(id, content) do
    Supervisor.child_spec(
      CacheWorker,
      start: {CacheWorker, :start_link, [id, content]},
      restart: :transient
    )
  end
end
