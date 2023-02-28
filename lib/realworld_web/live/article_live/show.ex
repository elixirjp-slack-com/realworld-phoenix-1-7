defmodule RealworldWeb.ArticleLive.Show do
  use RealworldWeb, :live_view

  alias Realworld.Blogs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    article = Blogs.get_article!(id)
    %{live_action: action, current_user: user} = socket.assigns

    if action == :edit && article.author_id != user.id do
      {:noreply, push_navigate(socket, to: ~p"/articles/#{article}")}
    else
      {:noreply,
      socket
      |> assign(:page_title, page_title(action))
      |> assign(:article, article)}
    end
  end

  defp page_title(:show), do: "Show Article"
  defp page_title(:edit), do: "Edit Article"
end
