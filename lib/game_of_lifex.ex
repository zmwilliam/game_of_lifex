defmodule GameOfLifex do
  @moduledoc """
  Documentation for `GameOfLifex`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> GameOfLifex.hello()
      :world

  """
  def hello do
    :world
  end

  def sow_blinker() do
    [{0, 0}, {1, 0}, {2, 0}]
    |> Enum.each(&Cell.sow/1)
  end

  def sow_diehard() do
    [{6, 2}, {0, 1}, {1, 1}, {1, 0}, {5, 0}, {6, 0}, {7, 0}]
    |> Enum.each(&Cell.sow/1)
  end

  def tick_and_sleep(n, sleep_time \\ 500) do
    1..n
    |> Enum.each(fn _ ->
      Universe.tick()
      :timer.sleep(sleep_time)
    end)
  end
end
