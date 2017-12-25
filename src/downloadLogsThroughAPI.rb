require 'fileutils'
require 'travis'


def getRepositoryLog(repo)
  parent_dir=File.join('..','build_logs',repo.gsub(/\//,'@'))
  #return if File.exist?(@parent_dir)
  FileUtils.mkdir_p(parent_dir) unless File.exist?(parent_dir)
  begin
    repository=Travis::Repository.find(repo) 
  rescue
     sleep 5
     retry
  end

  lastBuildNumber=repository.last_build.number
  for i in 4899..lastBuildNumber.to_i
    build=repository.build(i)
    build.jobs.each do |job|
      name=File.join(parent_dir, "#{job.number.gsub(/\./,'@')}.log")
      next if File.exist?(name)
      p name
      File.open(name,'w') do |file|
        flag=0
        begin
          file.write(job.log.clean_body)#存在这种错误undefined method `gsub' for nil:NilClass,估计会调用gsub方法
        rescue
          puts "flag=#{flag}"
          puts $!
          sleep 5
          flag=flag+1
          retry if flag<10
        end
      end
    end
  end

end

def eachRepository
=begin
  CSV.foreach(@input_CSV,headers:true) do |row|
    getRepositoryLog("#{row[0]}/#{row[1]}") if row[2].to_i != 0
  end
=end
	getRepositoryLog("junit-team/junit5")
end
eachRepository
