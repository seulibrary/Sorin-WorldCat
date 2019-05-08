defmodule SorinWorldcat do
  import SweetXml

  @doc """
  High-level function for querying Worldcat's Search (SRU) API.

  Takes a query string as a string, a search limit as an integer, and an offset
  as an integer.

  Returns a map containing the number of results, and a list of results
  formatted like Sorin Resource structs.

  Queries sorin.exs for certain fields required by Worldcat's API.

  ## Example

      iex> search("Proust", 2, 0, %{})
      {num_results: 159875, results: [%{}, %{}]}


  """
  def search(search_string, limit, offset, _filters \\ nil) do
    # Filter parsers must be implemented locally according to
    # a given instance's filter panel design; so the argument
    # is discarded by default.
    xml = send_query(search_string, limit, offset + 1)

    results =
      xml
      |> SweetXml.xpath(~x"//record"l)
      |> Stream.map(&extract_fields(&1))
      |> Enum.to_list()

    number_of_results =
      xml
      |> SweetXml.xpath(~x"//numberOfRecords/text()"i)

    %{num_results: number_of_results, results: results}
  end

  @doc """
  Low-level helper function for querying Worldcat's Search (SRU) API.

  Takes a query string as a string, a search limit as an integer, and an offset
  as an integer.

  Returns unformatted results.

  """
  def send_query(search_string, limit, offset) do
    formatted_search_string =
      search_string
      |> URI.encode_www_form()

    ("http://www.worldcat.org/webservices/catalog/search/sru?" <>
       "query=srw.kw+all+%22#{formatted_search_string}%22" <>
       "&wskey=#{Application.get_env(:sorin_worldcat, :wskey)}" <>
       "#{Application.get_env(:sorin_worldcat, :result_format)}" <>
       "&maximumRecords=#{limit}" <>
       "&startRecord=#{offset}")
    |> HTTPoison.get!()
    |> Map.get(:body)
  end

  @doc """
  Low-level helper function for mapping Worldcat Search (SRU) API query result
  fields to a map with the same fields as a Resource struct.

  """
  def extract_fields(record) do
    %{
      "contributor" =>
        SweetXml.xpath(record, ~x"//dc:contributor/text()"sl)
        |> nilify_empty(),
      "creator" =>
        SweetXml.xpath(record, ~x"//dc:creator/text()"sl)
        |> nilify_empty(),
      "date" =>
        SweetXml.xpath(record, ~x"//dc:date/text()"s)
        |> nilify_empty()
        |> return_last_four(),
      "description" =>
        SweetXml.xpath(record, ~x"//dc:description[1]/text()"s)
        |> nilify_empty(),
      "format" =>
        SweetXml.xpath(record, ~x"//dc:format/text()"s)
        |> nilify_empty(),
      "language" =>
        SweetXml.xpath(record, ~x"//dc:language[last()]/text()"s)
        |> nilify_empty(),
      "publisher" =>
        SweetXml.xpath(record, ~x"//dc:publisher/text()"s)
        |> nilify_empty(),
      "subject" =>
        SweetXml.xpath(record, ~x"//dc:subject/text()"sl)
        |> nilify_empty(),
      "title" =>
        SweetXml.xpath(record, ~x"//dc:title/text()"s)
        |> nilify_empty(),
      "type" =>
        SweetXml.xpath(record, ~x"//dc:type/text()"s)
        |> nilify_empty()
    }
  end

  defp nilify_empty(field) do
    case field do
      [] -> nil
      "" -> nil
      _ -> field
    end
  end

  defp return_last_four(field) when is_binary(field) do
    String.slice(field, -4..-1)
  end

  defp return_last_four(field) when is_nil(field), do: nil
end
