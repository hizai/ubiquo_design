class Ubiquo::StaticPagesController < UbiquoAreaController
  ubiquo_config_call :design_access_control, {:context => :ubiquo_design}  
  before_filter :load_page_templates
  before_filter :load_page, :only => [:edit, :update, :destroy]  
  before_filter :load_parent_pages, :except => [:index, :destroy]
  uses_tiny_mce(:options => default_tiny_mce_options, 
                :only => [:edit, :update, :create, :new])
  helper :pages
  def index
    order_by = params[:order_by] || Ubiquo::Config.context(:ubiquo_design).get(:pages_default_order_field)
    sort_order = params[:sort_order] || Ubiquo::Config.context(:ubiquo_design).get(:pages_default_sort_order)
    
    filters = { :text => params[:filter_text] }
    per_page = Ubiquo::Config.context(:ubiquo_design).get(:pages_elements_per_page)
    @static_pages_pages, @static_pages = Page.paginate(:page => params[:page], :per_page => per_page) do 
      Page.drafts.statics.filtered_search(filters, :order => order_by + " " + sort_order)
    end
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @static_pages }
    end
  end
  
  def new
    @static_page = Page.new(:is_static => true)
    @widget = StaticSection.new
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @static_page }
    end
  end
  
  def create
    default_page_params = { :is_static => true }
    default_widget_params = { :name => "Static Section" }
    @static_page = Page.new(params[:page].merge!(default_page_params))
    @widget = StaticSection.new(params[:static_section].reverse_merge!(default_widget_params))
    if params[:publish_page] == "true"
      ok = @static_page.add_widget(:main, @widget) && @static_page.publish
    else
      ok = @static_page.add_widget(:main, @widget)
    end
    respond_to do |format|
      if ok
        flash[:notice] = t("ubiquo.design.page_created")
        format.html { redirect_to ubiquo_static_pages_path }
        format.xml  { render :xml => @static_page, 
                             :status => :created, 
                             :location => @static_page }
      else
        flash[:error] = t("ubiquo.design.page_create_error")
        format.html { render :action => "new" }
        format.xml  { render :xml => @static_page.errors, 
                             :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @static_page = Page.find(params[:id])
    @widget = @static_page.static_section_widget
  end
  
  def update
    @static_page = Page.find(params[:id])
    @widget = @static_page.static_section_widget
    if params[:publish_page] == "true"
      ok = @static_page.update_attributes(params[:page]) && @widget.update_attributes(params[:static_section]) && @static_page.publish
    else
      ok = @static_page.update_attributes(params[:page]) && @widget.update_attributes(params[:static_section])
    end
    respond_to do |format|
      if ok
        flash[:notice] = t("ubiquo.design.page_edited")
        format.html { redirect_to ubiquo_static_pages_path }
        format.xml { head :ok }
      else
        flash[:error] = t("ubiquo.design.page_edit_error")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @static_page.errors,
                             :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @static_page = Page.find(params[:id])
    if @static_page.destroy
      flash[:notice] = t("ubiquo.design.page_removed")
    else
      flash[:error] = t("ubiquo.design.remove_error")
    end
    
    respond_to do |format|
      format.html { redirect_to ubiquo_static_pages_path }
      format.xml  { head :ok }
    end
  end

  def publish
    @static_page = Page.find(params[:id])
    if @static_page.publish
      flash[:notice] = t('ubiquo.design.page_published')
    else
      flash[:error] = t('ubiquo.design.page_publish_error')
    end
    redirect_to :action => "edit"
  end
  
  private
  
  def load_page_templates
    @page_templates = Page.templates
  end

  def load_page
    @page = Page.find(params[:id])    
  end
  
  def load_parent_pages
    @pages = Page.drafts.all(:conditions => ["url_name != ''"]) - [@page]
  end
  
end
