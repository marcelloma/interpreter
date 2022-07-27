defmodule Env do
  def value_of(id, [frame | env]) do
    if Map.has_key?(frame, id),
      do: Map.get(frame, id),
      else: value_of(id, env)
  end

  def value_of(id, []), do: raise("#{id} is undefined")

  def set_value_of(id, type, env), do: [%{id => type} | env]
end
