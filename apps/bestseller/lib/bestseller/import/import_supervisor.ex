defmodule Bestseller.Import.ImportSupervisor do
  @moduledoc """
  This should be the supervisor for the initial data import
  process to create the 500 static pages from the 500 most
  searched isbn
"""
  use Supervisor
  require Logger
  alias Bestseller.Import.ImportPipeline

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    Logger.debug("#{inspect(self())} Starting the
    Import Pipeline Supervisor module...")

    Supervisor.init([ImportPipeline], strategy: :one_for_one)
  end
end
