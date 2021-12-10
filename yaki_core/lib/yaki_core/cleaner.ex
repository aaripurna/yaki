defmodule YakiCore.Cleaner do
  @moduledoc """
  This module is used to clean the temp file after creating the temp file
  """

  @allowed_media_types ~w(.jpg .jpeg .png .gif .bmp .webp)

  @spec is_media_file?(String.t()) :: boolean()
  def is_media_file?(file_path) do
    file_ext = Path.extname(file_path)

    File.exists?(file_path) &&  Enum.member?(@allowed_media_types, file_ext)
  end

  @spec delete(String.t()) :: :ok | {:error, atom}
  def delete(file_path) do
    if is_media_file?(file_path) do
      File.rm(file_path)
    else
      {:error, :not_found}
    end
  end
end
