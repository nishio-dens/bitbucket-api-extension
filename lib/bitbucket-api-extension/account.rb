# coding: utf-8

module BitbucketApiExtension
  class Account

    include Virtus

    attribute :user_id, String
    attribute :user_password, String

  end
end
