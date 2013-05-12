# coding: utf-8

module BitbucketApiExtension
  class Project

    include Virtus

    attribute :name, String
    attribute :organization_name, String
  end
end
