defmodule Universe do
  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def tick() do
    GenServer.call(__MODULE__, {:tick})
  end

  def reset() do
    GenServer.call(__MODULE__, {:reset})
  end

  ##

  def handle_call({:reset}, _from, _state) do
    get_cells()
    |> Enum.each(&Cell.reap/1)

    {:reply, :ok, []}
  end

  def handle_call({:tick}, _from, _state) do
    get_cells()
    |> tick_each_process()
    |> wait_for_ticks()
    |> reduce_ticks()
    |> reap_and_sow()

    {:reply, :ok, []}
  end

  defp get_cells, do: Cell.Supervisor.children()

  defp tick_each_process(processes) do
    Enum.map(processes, &Task.async(fn -> Cell.tick(&1) end))
  end

  defp wait_for_ticks(tasks) do
    Enum.map(tasks, &Task.await/1)
  end

  defp reduce_ticks(ticks), do: Enum.reduce(ticks, {[], []}, &accumulate_ticks/2)

  defp accumulate_ticks({reap, sow}, {acc_reap, acc_sow}) do
    {acc_reap ++ reap, acc_sow ++ sow}
  end

  defp reap_and_sow({to_reap, to_sow}) do
    Enum.map(to_reap, &Cell.reap/1)
    Enum.map(to_sow, &Cell.sow/1)
  end
end
