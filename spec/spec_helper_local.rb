# frozen_string_literal: true

# This module's Bolt task plugins depend on shared Ruby libraries shipped by
# other Forge modules declared in .fixtures.yml (installed by `rake
# spec_prep`). Bolt's task runner stages those as sibling directories at
# execution time; a bare `rspec` process never does that staging, so require
# each dependency here by its one literal resolved path -- unambiguous about
# exactly what's loaded and from where, and a single place to audit.
FIXTURE_HELPER_LIBS = [
  'fixtures/modules/ruby_task_helper/files/task_helper.rb',
].freeze

FIXTURE_HELPER_LIBS.each do |relative_path|
  path = File.join(__dir__, relative_path)

  if File.exist?(path)
    require path
  else
    warn "spec_helper_local: #{path} not found -- run `bundle exec rake spec_prep` first if a spec requires it."
  end
end
