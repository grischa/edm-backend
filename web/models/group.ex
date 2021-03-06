defmodule EdmBackend.Group do
  @moduledoc """
  Represents client groups, and group hierarchies
  """

  require Logger
  use EdmBackend.Web, :model
  alias EdmBackend.Repo
  alias EdmBackend.Destination
  alias EdmBackend.Group
  alias EdmBackend.GroupMembership

  schema "groups" do
    field :name, :string
    field :description, :string
    has_many :children, Group, foreign_key: :parent_id, on_delete: :delete_all
    belongs_to :parent, Group, foreign_key: :parent_id
    has_many :group_memberships, GroupMembership, on_delete: :delete_all
    has_many :clients, through: [:group_memberships, :client]
    has_many :destinations, Destination
    timestamps
  end

  @allowed ~w(name description)a
  @required ~w(name description)a

  def changeset(model, params \\ %{}) do
    model |> cast(params, @allowed)
          |> cast_assoc(:parent, required: false)
          |> validate_required(@required)
          |> unique_constraint(:name, name: :groups_unique_null_parent_id)
          |> unique_constraint(:name, name: :groups_unique_not_null_parent_id)
  end

  @doc """
  Returns a list of clients who are members of this group of any of its children
  """
  def members(group) do
    group = group |> load_children
    members([group], [])
  end

  defp members([group|remaining_groups], member_list) do
    %{clients: members} = group |> Repo.preload(:clients)
    members(remaining_groups ++ group.children, member_list ++ members)
  end

  defp members([], member_list) do
    member_list
  end

  # Recursive loading code from http://tensiondriven.github.io/posts/recursively-load-self-referential-association-using-ecto
  @recursion_limit 10

  @doc """
    Recursively loads parents into the given struct until it hits nil
  """
  def load_parents(parent), do: load_parents(parent, @recursion_limit)

  def load_parents(parent, limit) when limit < 0, do: parent

  def load_parents(%Group{parent: nil} = parent, _), do: parent

  def load_parents(%Group{parent: %Ecto.Association.NotLoaded{}} = parent, limit) do
    parent = parent |> Repo.preload(:parent)
    load_parents(parent, limit)
  end

  def load_parents(%Group{} = parent, limit) do
    Map.update!(parent, :parent, &Group.load_parents(&1, limit - 1))
  end

  def load_parents(nil, _), do: nil

  @doc """
    Recursively loads children into the given struct until it hits []
  """
  def load_children(model), do: load_children(model, @recursion_limit)

  def load_children(children, limit) when limit < 0, do: children

  def load_children(%Group{children: %Ecto.Association.NotLoaded{}} = model, limit) do
    model = model |> Repo.preload(:children)
    load_children(model, limit)
  end

  def load_children(%Group{} = model, limit) do
    Map.update!(model, :children, fn(list) ->
      Enum.map(list, &Group.load_children(&1, limit - 1))
    end)
  end

end
