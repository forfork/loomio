module HasMentions
  extend ActiveSupport::Concern
  include Twitter::Extractor

  included do
    has_many :events, -> { includes :user }, as: :eventable, dependent: :destroy
    has_many :notifications, through: :events
  end

  module ClassMethods
    def is_mentionable(on: [])
      define_singleton_method :mentionable_fields, -> { Array on }
    end
  end

  def mentioned_group_members
    group.members.where(username: mentioned_usernames)
  end

  def mentioned_usernames
    extract_mentioned_screen_names(mentionable_text).uniq - [self.author.username]
  end

  def users_to_not_mention
    User.none # overridden with specific users to not receive mentions
  end

  private

  def mentionable_text
    self.class.mentionable_fields.map { |field| self.send(field) }.join('|')
  end

end
