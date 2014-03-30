Fixture::Application.set_routes do
  match 'foo/:id/bar', :to => 'foo#bar', :methods => [:get, :post]
  match 'this/:path/is/:very_awesome', :to => 'awesome#rad'
  scope :module => 'goose' do
    match 'lumpies/:lump', :to => 'lumpies#show', :methods => [:get]
  end
  scope :module => 'goose/wombat' do
    match 'rabbits/:chew', :to => 'rabbits#chew', :methods => [:get]
  end
  match '/', :to => 'root#vegetable', :methods => [:get]
  match '/', :to => 'root#no_vegetable', :methods => [:delete]
  match 'for_reals/:parbles', :to => 'for_reals#srsly', :methods => [:get]
end