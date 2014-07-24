
desc 'Compile all CoffeeScript files'
task :compile do
  puts 'Compiling all CoffeeScript files...'
  sh 'coffee -o tmp -c lib spec'
  puts 'Done.'
end

desc 'Run package specs'
task :spec do
  puts 'Running package specs...'
  sh 'apm test'
end

desc 'Run CoffeeLint'
task :lint do
  puts 'Running CoffeeLint...'
  sh 'coffeelint lib spec'
end

task default: [:compile, :spec, :lint]

# Cannot run `apm test` on CI since Atom is still closed beta.
task ci: [:compile, :lint]
