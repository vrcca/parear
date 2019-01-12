defprotocol Parear.Repository do
  @doc "Retrieves a value by its id. It returns either {:ok, term}, {:error, reason} or {:none}"
  def find_by_id(term)

  @doc "Retrieves a value by its name. It returns either {:ok, term}, {:error, reason} or {:none}"
  def find_by_name(term)

  @doc "Saves a value. It returns either {:ok, term} or {:error, reason}"
  def save(term)
end
