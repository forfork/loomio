module Null::User
  # include HasAvatar
  include Null::Object

  def can?(*args)
    ability.can?(*args)
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def nil_methods
    [:key, :username, :short_bio, :selected_locale, :deactivated_at, :time_zone,
     :default_membership_volume, :unsubscribe_token, :slack_identity, :location,
     :encrypted_password, :associate_with_identity, :update_attribute, :last_seen_at]
  end

  def false_methods
    [:is_logged_in?, :is_member_of?, :is_admin_of?, :is_admin?, :uses_markdown?,
     :email_when_proposal_closing_soon, :email_missed_yesterday, :has_password,
     :email_when_mentioned, :email_on_participation, :email_verified, :email_verified?]
  end

  def empty_methods
    [:groups, :group_ids, :adminable_group_ids]
  end

  def hash_methods
    [:experiences]
  end

  def true_methods
    [:angular_ui_enabled, :angular_ui_enabled?]
  end

  def none_methods
    {
      notifications: :notification,
      login_tokens: :login_token,
      memberships: :membership,
      participated_polls: :poll,
      group_polls: :poll,
      polls: :poll,
      stances: :stance
    }
  end

  def identities
    Identities::Base.none
  end

  def is_admin?
    false
  end
end
