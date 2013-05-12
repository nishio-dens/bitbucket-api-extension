# coding: utf-8

module BitbucketApiExtension
  class PullRequest

    include Virtus

    attribute :id, String
    attribute :title, String
    attribute :request_page_url, String
    attribute :author, String
  end
end
