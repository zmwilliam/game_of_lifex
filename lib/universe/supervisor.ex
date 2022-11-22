defmodule Universe.Supervisor do
  use Supervisor

  def start(_type, _args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      {Universe, []},
      {Cell.Supervisor, []},
      {Registry, [keys: :unique, name: Cell.Registry]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
