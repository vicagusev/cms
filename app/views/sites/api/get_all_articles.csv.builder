xml.instruct!
xml.articles{
  for article in @articles
    xml.article {
      xml.category_id(article[:category_id])
      xml.article_id(article[:article_id])
      xml.slug(article[:slug])
      xml.updated_at(article[:updated_at])
      xml.author(article[:author])
      xml.title(article[:title])
      xml.description(article[:description])
      xml.body('<![CDATA[>' + article[:body].gsub(/ & /, ' &amp;').gsub(/\]\]/, ']]]]><![CDATA[>') + ']]')
      xml.num_of_comments(article[:num_of_comments])
      xml.image(article[:image])
    }
  end
}