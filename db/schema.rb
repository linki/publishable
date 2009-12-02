ActiveRecord::Schema.define(:version => 0) do
  create_table :models, :force => true do |t|
    t.datetime :published_at
  end
end