# frozen_string_literal: true

class Item < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include MeiliSearch::Rails
  extend Pagy::Meilisearch

  # associations
  belongs_to :feed, counter_cache: true

  # validations
  validates :title, presence: true
  validates :url, presence: true, uniqueness: true
  validates :external_id, presence: true, uniqueness: true

  # scopes
  scope :latest, -> { order(published_at: :desc) }

  # search
  meilisearch do
    attribute :title, :text, :url, :categories, :published_at, :published_at_timestamp, :feed_id
    searchable_attributes %i[title text url categories published_at feed_id]

    filterable_attributes %i[feed_id categories published_at published_at_timestamp]
    sortable_attributes %i[published_at published_at_timestamp title]

    ranking_rules [
      'proximity',
      'typo',
      'words',
      'attribute',
      'sort',
      'exactness',
      'publication_year:desc'
    ]

    attribute :feed_title do
      feed.title
    end

    attribute :feed_url do
      feed.url
    end
  end

  def self.to_csv
    attributes = %w[feed_title feed_url title text url categories published_at]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |item|
        csv << attributes.map { |attr| item.send(attr) }
      end
    end
  end

  def feed_title
    feed.title
  end

  def feed_url
    feed.url
  end

  def text
    strip_tags(body.presence || title).to_s.squish
  end

  def published_at_timestamp
    published_at.to_i
  end
end
