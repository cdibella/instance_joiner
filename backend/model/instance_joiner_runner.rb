class InstanceJoinerRunner < JobRunner


  def self.instance_for(job)
    if job.job_type == "instance_joiner_job"
      self.new(job)
    else
      nil
    end
  end

  def join_instances( record )
    begin   
      @job.write_output( "Processing record : #{record.id}" ) 
  
      instances = case record
                    when Resource 
                      Instance.filter(:resource_id => record.id ).select(:id).map { |r| r[:id] } 
                    else
                      Instance.filter(:archival_object_id => record.id ).select(:id).map { |r| r[:id] } 
                    end

      if instances.length > 1
        @job.write_output( "Multiple instances found for record : #{record.id}" ) 
        containers = Container.filter( :instance_id => instances ).limit(3).all
        master = containers.shift
        containers.each_with_index do | container, i|
          pos = i + 2
          type = "type_#{pos}=".intern
          indicator = "indicator_#{pos}=".intern
          
          master.send( type, container.type_1 )
          master.send( indicator, container.indicator_1 )
          container.delete  
        end
        instances.shift 
        Instance.filter(:id => instances).delete 
        master.save 
      end

      record.children.each do |child|
        join_instances(child)
      end

    rescue Exception => e 
      @job.write_output(e.message)
      @job.write_output(e.backtrace)
    end
  end 
  

  def run
    super

    job_data = @json.job


    begin
      DB.open( DB.supports_mvcc?, 
             :retry_on_optimistic_locking_fail => true ) do
        begin
          RequestContext.open( :current_username => @job.owner.username,
                              :repo_id => @job.repo_id) do  

            @job.write_output( "Starting instance joiner job on repo : #{@job.repo_id}" ) 
            
            Resource.filter(:repo_id => @job.repo_id).each do | resource | 
              @job.write_output(" working on #{resource.id} ") 
              join_instances(resource)
            end

            @job.write_output( "Finishing #{target.id}" ) 
          end 
        rescue Exception => e
          terminal_error = e
          raise Sequel::Rollback
        end
      end
    
    rescue
      terminal_error = $!
    end
 
    if terminal_error
      @job.write_output(terminal_error.message)
      @job.write_output(terminal_error.backtrace)
      
      raise terminal_error
    end
    
    @job.write_output("done..")

  end



end
