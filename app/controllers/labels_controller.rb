class LabelsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @label_pages, @labels = paginate :labels, :per_page => 10
  end

  def show
    @label = Label.find(params[:id])
  end

  def new
    @label = Label.new
   	@label_types = [["Select Label Type", "0"]] + LabelType.select_all_types
  end

  def create
    label = params[:label]
    lt_id = label[:label_type]
    lt = LabelType.find(lt_id)
    @label = Label.new(:hrid => label[:hrid], :label_type => lt, :user => getSessionUser)
    if @label.save
      flash[:notice] = 'Label was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @label = Label.find(params[:id])
   	@label_types = [["Select Label Type", "0"]] + LabelType.select_all_types
   	@label_descr = @label.label_descs
  end

  def update
    @label = Label.find(params[:id])
    if @label.update_attributes(params[:label])
      flash[:notice] = 'Label was successfully updated.'
      redirect_to :action => 'show', :id => @label
    else
      render :action => 'edit'
    end
  end

  def destroy
    Label.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
