class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :btype
      t.string :bvin
      t.string :bweather

      t.timestamps
    end
  end
end
