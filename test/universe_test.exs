defmodule UniverseTest do
  use ExUnit.Case

  setup do
    on_exit(fn ->
      Cell.Supervisor.children()
      |> Enum.each(&Cell.reap/1)
    end)

    :ok
  end

  describe "blink pattern" do
    test "count_neighbors/1" do
      cases = [
        %{position: {-1, 0}, expectedNeighbors: 1},
        %{position: {1, 0}, expectedNeighbors: 1},
        %{position: {0, 0}, expectedNeighbors: 2}
      ]

      Enum.each(cases, &Cell.sow(&1.position))

      Enum.each(cases, &assert_neighbors(&1.position, &1.expectedNeighbors))

      # Enum.each(cases, fn %{position: position, expectedNeighbors: expectedNeighbors} ->
      #   gotNeighbors = Cell.lookup(position) |> Cell.count_neighbors()
      #
      #   assert expectedNeighbors == gotNeighbors,
      #          "expected position #{inspect(position)} to have #{expectedNeighbors} neighbors, got #{gotNeighbors}"
      # end)
    end
  end

  describe "block pattern" do
    test "count_neighbors/1 should be the same for all positions" do
      positions = [{0, 1}, {1, 1}, {0, 0}, {1, 0}]

      Enum.each(positions, &Cell.sow/1)

      Enum.each(positions, &assert_neighbors(&1, 3))
    end

    test "Universe.tick/0 should not change positions" do
      positions = [{0, 1}, {1, 1}, {0, 0}, {1, 0}]

      Enum.each(positions, &Cell.sow/1)

      assert_iteration(positions)
    end
  end

  defp assert_iteration(iterations) do
    Universe.tick()

    expected = Enum.sort(iterations)

    got =
      Cell.Supervisor.children()
      |> Enum.map(&Registry.keys(Cell.Registry, &1))
      |> List.flatten()
      |> Enum.sort()

    assert expected == got
  end

  defp assert_neighbors(position, expectedNeighbors) do
    gotNeighbors = Cell.lookup(position) |> Cell.count_neighbors()

    assert expectedNeighbors == gotNeighbors,
           "expected position #{inspect(position)} to have #{expectedNeighbors} neighbors, got #{gotNeighbors}"
  end
end
