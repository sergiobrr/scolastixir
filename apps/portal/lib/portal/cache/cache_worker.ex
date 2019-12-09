defmodule Portal.Cache.CacheWorker do
  @moduledoc """
    This module implements a service wich cache for at least 60 seconds
    a page content. It can manage 3 types of internal messages:
        - :get_content
        - :refresh
        - :expire
        - :unexpected messages aren't blocking
    It's under supervisor and it use GenServer
  """
  use GenServer
  require Logger

  @expire_time 60_000

  def start_link(content_id, content) do
    GenServer.start_link(
      __MODULE__,
      content,
      name: name_for(content_id)
    )
  end

  def name_for(content_id), do: {:global, {:cache, content_id}}

  def init(content) do
    timer = Process.send_after(self(), :expire, @expire_time)
    Logger.debug("#{inspect(self())}: CacheWorker started.
    Will expire in #{Process.read_timer(timer)} milliseconds.")

    {:ok, %{hits: 0, content: content, timer: timer}}
  end

  def handle_info(:expire, %{hits: hits} = state) do
    Logger.debug("#{inspect(self())}: Terminating process...
    Served the cached content #{hits} times.")
    {:stop, :normal, state}
  end

  def handle_info(msg, state) do
    super(msg, state)
  end

  def get_content(pid), do: GenServer.call(pid, :get_content)

  def handle_call(:get_content, _from, %{hits: hits, content: content, timer: timer} = state) do
    Logger.debug("#{inspect(self())}: Received :get_content
    and served #{byte_size(content)} bytes #{hits+1} times.")

    new_timer = refresh_timer(timer)

    {:reply, {:ok, content}, %{state | hits: hits + 1, timer: new_timer}}
  end

  def refresh(pid), do: GenServer.cast(pid, :refresh)

  def handle_cast(:refresh, %{timer: timer} = state),
    do: {:noreply, %{state | timer: refresh_timer(timer)}}

  defp refresh_timer(timer) do
    Process.cancel_timer(timer)
    new_timer = Process.send_after(self(), :expire, @expire_time)
    expires_in = Process.read_timer(new_timer)

    Logger.debug("#{inspect(self())}: Canceled the previous
    expiration timer. Will now expire in
    #{expires_in} milliseconds.")

    new_timer
  end
end
