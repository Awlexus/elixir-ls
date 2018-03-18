defmodule ElixirLS.LanguageServer.Providers.Formatting do
  alias ElixirLS.LanguageServer.SourceFile

  def supported? do
    :erlang.function_exported(Code, :format_string!, 2)
  end

  def format(source_file, project_dir) do
    opts = formatter_opts(project_dir)
    formatted = IO.iodata_to_binary([Code.format_string!(source_file.text, opts), ?\n])

    response = [
      %{"newText" => formatted, "range" => SourceFile.full_range(source_file)}
    ]

    {:ok, response}
  end

  defp formatter_opts(nil) do
    []
  end

  defp formatter_opts(project_dir) do
    dot_formatter = Path.join(project_dir, ".formatter.exs")

    if File.regular?(dot_formatter) do
      {formatter_opts, _} = Code.eval_file(dot_formatter)

      unless Keyword.keyword?(formatter_opts) do
        Mix.raise(
          "Expected #{inspect(dot_formatter)} to return a keyword list, " <>
            "got: #{inspect(formatter_opts)}"
        )
      end

      formatter_opts
    else
      []
    end
  end
end
