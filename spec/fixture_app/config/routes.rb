Fixture::Application.set_routes do
  match 'foo/:id/bar', :to => 'foo#bar', :methods => [:get, :post]
  match 'this/:path/is/:very_awesome', :to => 'awesome#rad'
  scope :method => [:get] do
    scope :module => 'goose' do
      match 'lumpies/:lump', :to => 'lumpies#show'
    end
    scope :module => 'goose/wombat' do
      match 'rabbits/:chew', :to => 'rabbits#chew'
    end
  end
  match '/', :to => 'root#vegetable', :methods => [:get]
  match '/', :to => 'root#no_vegetable', :methods => [:delete]
  match 'for_reals/switching', :to => 'for_reals#switching', :methods => [:get]
  match 'for_reals/:parbles', :to => 'for_reals#srsly', :methods => [:get]
end