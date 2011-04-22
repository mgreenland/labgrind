class ProjectsController < ApplicationController
  before_filter :require_user
  
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])
    @owners = ProjectAssignment.find(:all, :conditions => { :project_id => @project.id, :owner => 1 })

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @users = User.all
    @owners = ProjectAssignment.find(:all, :conditions => { :project_id => @project.id, :owner => 1 })
    @passed_owners = params[:owners]
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])
    @project.users << current_user
    
    respond_to do |format|
      if @project.save
        @project.set_owner(current_user)
        format.html { redirect_to(@project, :notice => 'Project was successfully created.') }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        @passed_members = params[:members]
        @passed_owners = params[:owners]
        
        p_users_array = @project.users.map { |user| User.find(user.id).becomes(User).id.to_i }
        
        @project.users = @project.users - @project.owners
        
        if !@passed_members.nil?
          @passed_members.each do |member|
            if !@project.users.include?(member)
              @project.users << User.find(member.to_i)
            end
          end
        end
        
        format.html { redirect_to(@project, :notice => 'Project successfully updated') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end