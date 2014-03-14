
desc 'Compile all CoffeeScript files'
task :compile do
  puts 'Compiling all CoffeeScript files...'
  system('coffee -o tmp -c lib spec') || fail
  puts 'Done.'
end

desc 'Run package specs'
task :spec do
  puts 'Running package specs...'
  system('apm test') || fail
end

desc 'Run CoffeeLint'
task :lint do
  puts 'Running CoffeeLint...'
  system('coffeelint lib spec') || fail
end

task default: [:compile, :spec, :lint]

# Cannot run `apm test` on CI since Atom is still closed beta.
task ci: [:compile, :lint]
