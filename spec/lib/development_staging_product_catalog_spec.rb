# frozen_string_literal: true

require "spec_helper"
require Rails.root.join("lib/development_staging_product_catalog")

RSpec.describe DevelopmentStagingProductCatalog do
  EXPECTED_PRODUCTS = [
    ["Beautiful widget", "demo", nil, "demo"],
    ["Beautiful films widget", "film", "films", "demo_films"],
    ["Beautiful music-and-sound-design widget", "music", "music-and-sound-design", "demo_music_and_sound_design"],
    ["Beautiful writing-and-publishing widget", "writing", "writing-and-publishing", "demo_writing_and_publishing"],
    ["Beautiful education widget", "education", "education", "demo_education"],
    ["Beautiful software-development widget", "software", "software-development", "demo_software_development"],
    ["Beautiful comics-and-graphic-novels widget", "comics", "comics-and-graphic-novels", "demo_comics_and_graphic_novels"],
    ["Beautiful drawing-and-painting widget", "drawing", "drawing-and-painting", "demo_drawing_and_painting"],
    ["Beautiful 3d widget", "animation", "3d", "demo_three_d"],
    ["Beautiful audio widget", "audio", "audio", "demo_audio"],
    ["Beautiful gaming widget", "games", "gaming", "demo_gaming"],
    ["Beautiful photography widget", "photography", "photography", "demo_photography"],
    ["Beautiful self-improvement widget", "crafts", "self-improvement", "demo_self_improvement"],
    ["Beautiful design widget", "design", "design", "demo_design"],
    ["Beautiful fitness-and-health widget", "sports", "fitness-and-health", "demo_fitness_and_health"],
    ["Beautiful fiction-books widget", "merchandise", "fiction-books", "demo_fiction_books"],
  ].freeze

  it "publishes the exact stable 16-product identity and path contract" do
    products = described_class.products

    expect(products.map { [_1.name, _1.category, _1.taxonomy_slug, _1.permalink] }).to eq(EXPECTED_PRODUCTS)
    expect(products.map(&:permalink)).to contain_exactly(*EXPECTED_PRODUCTS.map(&:last))
    expect(products.map(&:permalink).uniq.size).to eq(16)
    expect(products.map(&:legacy_path)).to eq(products.map(&:next_path))
    expect(products.map(&:legacy_path)).to eq(products.map { |product| "/l/#{product.permalink}" })
    expect(described_class.surfaces).to eq(
      "legacy_host" => "legacy.gumroad.reactonrails.com",
      "next_host" => "next.gumroad.reactonrails.com",
    )
  end
end
