guard :minitest, all_after_pass: false, all_on_start: false do
  watch(%r{^spec/(.*)_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})         { |m| "spec/lib/#{m[1]}_spec.rb" }
end
