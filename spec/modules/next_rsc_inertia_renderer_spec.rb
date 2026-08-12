# frozen_string_literal: true

require "spec_helper"

RSpec.describe NextRscInertiaRenderer, type: :controller do
  render_views

  controller(ApplicationController) do
    def index
      render inertia: "Logins/New", props: { marker: "same-legacy-props" }
    end
  end

  before do
    routes.draw { get "index" => "anonymous#index" }
    allow_any_instance_of(ApplicationController).to receive(:inertia_shared_data).and_return({})
    allow(controller).to receive(:stream_view_containing_react_components) do |**options|
      page = options.fetch(:locals).fetch(:page)
      controller.render html: "next-rsc-page-root #{page[:component]} #{page[:props][:marker]}"
    end
  end

  around do |example|
    original = ENV[DemoRenderingSurface::ENV_NAME]
    ENV[DemoRenderingSurface::ENV_NAME] = rendering_surface
    example.run
  ensure
    ENV[DemoRenderingSurface::ENV_NAME] = original
  end

  let(:rendering_surface) { "next" }

  it "streams the unchanged Inertia page through RSC on the Next surface" do
    get :index

    expect(response).to be_successful
    expect(response.body).to include("next-rsc-page-root")
    expect(response.body).to include("Logins/New")
    expect(response.body).to include("same-legacy-props")
    expect(controller).to have_received(:stream_view_containing_react_components).with(
      hash_including(template: "next_rsc/page", layout: true),
    )
    expect(response.headers["X-Inertia"]).to be_nil
  end

  it "keeps the original Inertia response on the Legacy surface" do
    original = ENV[DemoRenderingSurface::ENV_NAME]
    ENV[DemoRenderingSurface::ENV_NAME] = "legacy"
    get :index
    ENV[DemoRenderingSurface::ENV_NAME] = original

    expect(response).to be_successful
    expect(response.body).to include("data-page")
    expect(response.body).not_to include("next-rsc-page-root")
  end

  it "does not return Inertia JSON for Next navigation requests" do
    request.headers["X-Inertia"] = "true"

    get :index

    expect(response).to be_successful
    expect(response.media_type).to eq("text/html")
    expect(response.headers["X-Inertia"]).to be_nil
    expect(response.body).to include("next-rsc-page-root")
  end
end
