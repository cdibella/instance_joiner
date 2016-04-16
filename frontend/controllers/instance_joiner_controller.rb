class InstanceJoinerController < ApplicationController

  set_access_control "manage_repository" => [ :index, :create]
  
  def index
    @job = JSONModel(:job).new._always_valid!
  end

  def create
    job_data ||= {}     
    job_data["repo_id"] ||= session[:repo_id] 

    job = Job.new('instance_joiner_job', JSONModel(:instance_joiner_job).from_hash( job_data ) , []) 
    upload = job.upload 
    resolver = Resolver.new(upload[:uri])
    redirect_to resolver.view_uri 

  end

end
