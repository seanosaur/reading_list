require "goodreads"
load "secrets.rb" # Needs KEY, SECRET, USER_ID constants

client = Goodreads::Client.new(api_key: KEY, api_secret: SECRET)

user = client.user(USER_ID)

last_status = user.updates[0].object.user_status

File.open("../data/to-read.yaml", "w") do |file|

  book_list = []
  sorted_books = []

  page = 1
  total_pages = 2 # Each page holds 200 books, adjust total_pages accordingly.

  while page <= total_pages do
    shelf = client.shelf(USER_ID, "to-read", sort: "author", per_page: 200, page: page)
    shelf.books.each do |book|
      book_list << book
    end

    page += 1
  end

  sorted_books << book_list.sort_by do |book|
    [book['book']['authors']['author']['name'].split[-1], book['book']['title']]
  end

  sorted_books[0].each do |book|
    author = book["book"]["authors"]["author"]["name"]
    title = book["book"]["title"]
    url = book["book"]["link"]
    file.puts "- author: #{author}\n  title:  \"#{title}\"\n  url:    \"#{url}\""
  end
end

if last_status.page
  File.open("../data/currently-reading.yaml", "w") do |file|
    author = last_status.book.author.name
    title = last_status.book.title
    total = last_status.book.num_pages
    page = last_status.page
    book_url = client.book(last_status.book_id).url
    file.puts "- author: #{author}\n  title:  \"#{title}\"\n  url:    \"#{book_url}\"\n  total:  #{total}\n  page:   #{page}"
  end
end
