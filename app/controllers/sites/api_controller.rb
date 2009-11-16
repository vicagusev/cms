class Sites::ApiController < ApplicationController

  def documentation
    respond_to do |format| 
      format.html
    end 
  end

  # GET http://mydomain.com/api/categories.format
  def get_categories
     @categories = @presenter.main_sections(2)
     respond_to do |format| 
       format.xml 
       format.html { render :text  => 'html content is not supported. Please try the same url with .xml extension' } 
     end 
  end
  
  # GET http://mydomain.com/api/articles.format
  def get_category_articles
    category_id = params[:category_id]
    unless category_id
      render :text  => 'Missing parameter: \'category_id\' is required'
      return
    end

    per_page = params[:per_page]
    page_num = params[:page_num]
    @articles = articles(category_id, per_page, page_num)
    respond_to do |format| 
      format.xml 
      format.html { render :text  => 'html content is not supported. Please try the same url with .xml extension' } 
    end 
  end

  # GET http://mydomain.com/api/article.format
  def get_article
    article_id = params[:article_id]
    @tree_node = TreeNode.find(article_id)
    respond_to do |format| 
      format.xml 
      format.html { render :text  => 'html content is not supported. Please try the same url with .xml extension' } 
    end 
  end
  
  # GET http://mydomain.com/api/article_comments.format
  def get_article_comments
    article_id = params[:article_id]
    unless article_id.is_integer?
      render :text  => "Invalid input syntax #{article_id}: \'article_id\' must be integer"
      return
    end
    limit = params[:per_page] || 1000
    page_num = params[:page_num] || 1
    page_num -= 1
    offset = limit * page_num
    
    @comments = Comment.list_all_comments_for_page(article_id, limit, offset)

    respond_to do |format| 
      format.xml 
      format.html { render :text  => 'html content is not supported. Please try the same url with .xml extension' } 
    end 
  end

  # GET http://mydomain.com/api/article_comment.format
  def get_article_comment
    comment_id = params[:comment_id]
    @comment = Comment.get_comment(comment_id)
  end
  
  # POST http://mydomain.com/api/article_comment.format
  def add_comment_to_article
    article_id = params[:article_id]
    args = Hash.new
    args[:title] = params[:title]
    args[:name] = params[:name]
    args[:email] = params[:email]
    args[:body] = params[:body]
    args[:is_valid] = 0
    args[:is_valid] = 200 if params[:is_valid] == '1'
    
    error_message = Hash.new
    error_message[:article_id] = "Missing parameter: \'article_id\' is required" if article_id.empty?
    error_message[:title] = "Missing parameter: \'title\' is required" if args[:title].empty?
    unless error_message.empty?
      render :xml  => {:respond => error_message}
      return
    end

    begin
      tree_node = TreeNode.find(article_id)
    rescue Exception => e
      render :xml  => {:respond => "Article not found: article ID:#{article_id}"}
      return
    end

    respond_to do |format|
      if Comment.create_comment(tree_node, args)
        format.html { render :text  => "Comment for article ID:#{article_id} created successfully" }
        format.xml  { render :xml  => {:respond => "Comment for article ID:#{article_id} created successfully"} }
      else
        format.html { render :text  => "Creation of comment for article ID:#{article_id} has failed" }
        format.xml  { render :xml  => {:respond => "Creation of comment for article ID:#{article_id} has failed"} }
      end
    end
    
  end
  
  # GET http://mydomain.com/api/article_comment.format
  def get_first_page_article
    
  end
  
  private
  # :current_page => 3 - integer - optional - default: paging is disabled
  # :items_per_page => 10 - integer - optional - default: 25 items per page(if current page key presents)
  
  def articles(parent_id, per_page = nil, page_num = nil)
    return nil unless parent_id
    args = {:parent => parent_id, 
    :resource_type_hrids => ['content_page'], 
    :depth => 1,
    :has_url => true,
    :properties => 'b_acts_as_section = false'
    }
    args
    if page_num
      args.merge!({:current_page => page_num})
      if per_page
        args.merge!({:items_per_page => per_page})
      end
    end
    TreeNode.get_subtree(args)
  end
  
end