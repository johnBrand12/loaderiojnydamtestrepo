configure :production, :development do
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres://ayxrzzugclatwa:c34ca20b2263d35cd8fc651e4963edb74ffcf4e55cf545b86c4ebf42d363db6f@ec2-3-230-122-20.compute-1.amazonaws.com:5432/d69ohe5iri937b')

    ActiveRecord::Base.establish_connection(
        :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
        :host => db.host,
        :username => db.user,
        :password => db.password,
        :database => db.path[1..-1],
        :encoding => 'utf8'
    )
end