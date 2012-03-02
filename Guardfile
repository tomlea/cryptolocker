# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :growl

guard :rspec, :cli => '--color --format doc', :notification => true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})         { |m| "spec" }
end

guard :bundler do
  watch('Gemfile')
  watch('Gemfile.lock')
end
