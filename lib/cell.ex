defmodule Cell do
  use GenServer

  # I use eval_string to avoid code formatter
  @offsets Code.eval_string("""
           [
             {-1,  1}, {0,  1}, {1,  1},
             {-1,  0},          {1,  0},
             {-1, -1}, {0, -1}, {1, -1},
           ]
           """)
           |> elem(0)

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(position) do
    GenServer.start_link(__MODULE__, position, name: {:via, Registry, {Cell.Registry, position}})
  end

  def reap(process_id) do
    Cell.Supervisor.terminate_child(process_id)
  end

  def sow(position) do
    Cell.Supervisor.start_child(position)
  end

  def tick(process) do
    GenServer.call(process, {:tick})
  end

  def count_neighbors(process) do
    GenServer.call(process, {:count_neighbors})
  end

  def lookup(position) do
    Cell.Registry
    |> Registry.lookup(position)
    |> Enum.map(fn
      {pid, _} -> pid
      nil -> nil
    end)
    |> Enum.find(&Process.alive?/1)
  end

  ##

  def handle_call({:tick}, _from, position) do
    to_reap =
      position
      |> do_count_neighbors()
      |> case do
        2 -> []
        3 -> []
        _ -> [self()]
      end

    to_sow =
      position
      |> neighboring_positions()
      |> keep_dead()
      |> keep_valid_children()

    {:reply, {to_reap, to_sow}, position}
  end

  def handle_call({:count_neighbors}, _from, position) do
    {:reply, do_count_neighbors(position), position}
  end

  defp do_count_neighbors(position) do
    position
    |> neighboring_positions()
    |> keep_live()
    |> length()
  end

  defp neighboring_positions({x, y}) do
    Enum.map(@offsets, fn {dx, dy} -> {x + dx, y + dy} end)
  end

  defp keep_live(positions), do: Enum.filter(positions, &(lookup(&1) != nil))
  defp keep_dead(positions), do: Enum.filter(positions, &(lookup(&1) == nil))

  defp keep_valid_children(positions) do
    Enum.filter(positions, &(do_count_neighbors(&1) == 3))
  end
end
