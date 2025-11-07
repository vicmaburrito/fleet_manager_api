class EnableCitextExtension < ActiveRecord::Migration[7.2]
  def change
    enable_extension "citext" unless extension_enabled?("citext")
  end
end
