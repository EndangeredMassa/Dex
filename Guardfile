guard :shell do
  watch /.*/ do |m|
    path = m[0]
    if %r{^(src|test).+$}.match path
      `rake test`
    end
  end
end
