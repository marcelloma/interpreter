defmodule TypeEnv do
  def type_of(id, [frame | t_env]) do
    if Map.has_key?(frame, id),
      do: Map.get(frame, id),
      else: type_of(id, t_env)
  end

  def type_of(id, []), do: raise("#{id} is undefined")

  def set_type_of(id, type, t_env), do: [%{id => type} | t_env]
end
