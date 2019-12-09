defmodule Bestseller.Import.ImportPipeline do
  @moduledoc """
  This should be the module responsible to load and import
  the most searched 500 isbn from isbn_db and to translate
  them to a complete page
"""

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :transient,
      shutdown: 10000,
      type: :worker
    }
  end

end

