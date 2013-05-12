# coding: utf-8

module BitbucketApiExtension
  class Comment

    include Virtus

    attribute :pull_request_id, Integer
    attribute :author_username, String
    attribute :author_display_name, String
    attribute :comment, String
  end
end
