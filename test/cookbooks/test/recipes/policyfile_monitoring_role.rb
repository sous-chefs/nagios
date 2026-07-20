# frozen_string_literal: true

# Policyfiles cannot include Chef roles in named run lists, so preserve only
# the role membership required by the data bag search fixtures.
node.automatic['roles'] = Array(node['roles']) | %w(monitoring)
