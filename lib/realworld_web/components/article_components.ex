defmodule RealworldWeb.ArticleComponents do
  use Phoenix.Component

  alias Realworld.Blogs.Article

  attr :article, Article, required: true

  def tags(assigns) do
    tag_names =
      assigns.article.tags
      |> Enum.map(fn %{tag: tag} -> tag end)
      |> Enum.join(", ")
    assigns = assign(assigns, :tag_names, tag_names)

    ~H"""
    <%= @tag_names %>
    """
  end
end
