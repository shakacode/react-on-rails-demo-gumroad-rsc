# frozen_string_literal: true

class DiscoverDomainConstraint
  def self.matches?(request)
    canonical_discover_host?(request.host) || control_plane_branch_discover_request?(request)
  end

  def self.canonical_discover_host?(host)
    host == VALID_DISCOVER_REQUEST_HOST
  end

  def self.control_plane_branch_host?(host)
    GumroadDomainConstraint.control_plane_branch_host?(host)
  end

  def self.control_plane_branch_discover_request?(request)
    return false unless control_plane_branch_host?(request.host)

    # Keep this to explicit Discover entrypoints so branch app roots still match
    # GumroadDomainConstraint and render the normal app shell.
    [
      "/discover",
      "/discover/categories",
      "/discover_search_autocomplete",
    ].include?(request.path) ||
      request.path.start_with?("/animation") ||
      DiscoverTaxonomyConstraint.matches?(request)
  end
  private_class_method :control_plane_branch_discover_request?
  private_class_method :control_plane_branch_host?
end
