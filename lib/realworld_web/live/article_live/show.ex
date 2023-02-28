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

  @impl true
  def handle_event("delete", _value, socket) do
    %{article: article, current_user: user} = socket.assigns

    if article.author_id != user.id do
      {:noreply, socket}
    else
      {:ok, _} = Blogs.delete_article(article)
      {:noreply,
       socket
       |> put_flash(:info, "Article deleted successfully")
       |> push_navigate(to: ~p"/articles")}
    end
  end

  defp page_title(:show), do: "Show Article"
  defp page_title(:edit), do: "Edit Article"
end
