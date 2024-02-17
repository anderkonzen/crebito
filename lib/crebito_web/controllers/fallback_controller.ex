defmodule CrebitoWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CrebitoWeb, :controller

  @doc false
  def call(conn, {:error, :client, %Ecto.Changeset{} = changeset, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CrebitoWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  @doc false
  def call(conn, {:error, :transaction, %Ecto.Changeset{} = changeset, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CrebitoWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  @doc false
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CrebitoWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  @doc false
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: CrebitoWeb.ErrorJSON)
    |> render(:"404")
  end
end
