defmodule Cell.Supervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one, restart: :transient)
  end

  def start_child(args) do
    DynamicSupervisor.start_child(__MODULE__, {Cell, args})
  end

  def terminate_child(process_id) do
    DynamicSupervisor.terminate_child(__MODULE__, process_id)
  end

  def children do
    Cell.Supervisor
    |> Supervisor.which_children()
    |> Enum.map(&Kernel.elem(&1, 1))
  end
end
