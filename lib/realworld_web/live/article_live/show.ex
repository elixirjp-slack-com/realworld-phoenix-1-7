defmodule RealworldWeb.ArticleLive.Show do
  use RealworldWeb, :live_view

  alias Realworld.Blogs
  alias Realworld.Blogs.Comment

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
      changeset = Blogs.change_comment(%Comment{})

      {:noreply,
      socket
      |> assign(:page_title, page_title(action))
      |> assign(:article, article)
      |> assign(:comment_form, to_form(changeset))}
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

  @impl true
  def handle_event("validate_comment", %{"comment" => comment_params}, socket) do
    changeset =
      %Comment{}
      |> Blogs.change_comment(comment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :comment_form, to_form(changeset))}
  end

  @impl true
  def handle_event("post_comment", %{"comment" => comment_params}, socket) do
    comment_params = 
      comment_params
      |> Map.put("article_id", socket.assigns.article.id)
      |> Map.put("author_id", socket.assigns.current_user.id)
    case Blogs.create_comment(comment_params) do
      {:ok, _} ->
        article = Blogs.get_article!(socket.assigns.article.id)
        changeset = Blogs.change_comment(%Comment{})

        {:noreply,
         socket 
         |> assign(:article, article)
         |> assign(:comment_form, to_form(changeset))
         |> put_flash(:info, "Comment posted successfully")}
      _ ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Article"
  defp page_title(:edit), do: "Edit Article"
end
