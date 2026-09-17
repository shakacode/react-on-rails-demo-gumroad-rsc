# frozen_string_literal: true

module NextRscInertiaRenderer
  def render
    return super unless DemoRenderingSurface.current(request: @request) == :next

    @controller.instance_variable_set("@_inertia_page", page)
    @controller.instance_variable_set("@hide_layouts", true)
    @controller.instance_variable_set("@skip_csrf_token_injection", true)
    @controller.stream_view_containing_react_components(
      template: "next_rsc/page",
      layout: layout,
      locals: @view_data.merge(
        page:,
        admin: @controller.class.name.start_with?("Admin::"),
        href: @request.original_url,
      ),
    )
  end
end

InertiaRails::Renderer.prepend(NextRscInertiaRenderer)
