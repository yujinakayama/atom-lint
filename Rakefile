
desc 'Compile all CoffeeScript files'
task :compile do
  puts 'Compiling all CoffeeScript files...'
  system('coffee -o tmp -c lib spec') || fail
  puts 'Done.'
end

desc 'Run package specs'
task :spec do
  puts 'Running package specs...'
  command = if ENV['CI']
              'curl -s https://raw.githubusercontent.com/atom/ci/master/build-package.sh | sh'
            else
              'apm test'
            end
  system(command) || fail
end

desc 'Run CoffeeLint'
task :lint do
  puts 'Running CoffeeLint...'
  system('coffeelint lib spec') || fail
end

task default: [:compile, :spec, :lint]
task ci: [:compile, :spec, :lint]
