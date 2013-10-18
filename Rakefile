require "rake/testtask"

FileList["tasks/*.rake"].each { |task| load task }

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList['spec/*_spec.rb']
end

task :default do
  system("rspec -c")
end
