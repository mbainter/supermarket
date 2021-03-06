#
# Cookbook Name:: build_cookbook
# Recipe:: smoke
#
# Copyright:: Copyright 2017 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# If there are every additional activities that you want to do while your
# omnibus test is happening (i.e. run inspec tests), you can do them
# here between the async trigger and the wait_for_complete.

#########################################################################
# Inspec Smoke Tests
#########################################################################

# Get a list of all the nodes that we need to test against
infra_nodes = infra_nodes_for(workflow_change_project, workflow_change_pipeline, workflow_stage)

supermarket_nodes = infra_nodes.find_all { |infra_node| infra_node['chef_product_key'] == 'supermarket' }
supermarket_fqdns = supermarket_nodes.map(&:name)

# We will run all our inspec commands in parallel, so add the profiles you want
# to execute to this array.
inspec_commands = []

# Tests to run against Supermarket instances in every environment
supermarket_smoke_tests = %w(
  supermarket-smoke
)
inspec_commands << inspec_commands_for(supermarket_smoke_tests, supermarket_fqdns, sudo: true)

# Execute all the tests in parallel (for speed!)
parallel_execute "Execute inspec smoke tests against #{workflow_stage}" do
  commands inspec_commands.flatten.uniq
  cwd workflow_workspace_repo
  environment(
    'PATH' => chefdk_path,
    'HOME' => workflow_workspace
  )
end
