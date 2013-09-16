Rory::Application.set_routes do
  match 'foo/:id/bar', :to => 'foo#bar', :methods => [:get, :post]
  match 'foo', :to => 'monkeys', :methods => [:put]
  match 'this/:path/is/:very_awesome', :to => 'awesome#rad'
end