# coding: utf-8

module BitbucketApiExtension; end

class BitbucketApiExtension::Api

  BITBUCKET_URI = 'https://bitbucket.org'
  BITBUCKET_API_URI = 'https://api.bitbucket.org/1.0/repositories'

  attr_reader :account, :project

  def initialize(options = {})
    @account = options[:account]
    @project = options[:project]
  end

  # プルリクエスト一覧を取得する
  def pull_requests
    uri = pull_request_list_url(@project.organization_name, @project.name)
    auth_options = if @account.nil?
                     {}
                   else
                     {http_basic_authentication: [@account.user_id, @account.user_password]}
                   end
    list = []
    open(uri, auth_options) do |f|
      html = Nokogiri::HTML(f.read).xpath('//table[contains(@class,"pullrequest-list")]/tbody/tr')
      list = html.map do |request|
        title = request.xpath('td[@class="title"]/div/a').text
        PullRequest.new(title: title,
                        id: title.scan(/#(\d+):.*/)
                                 .flatten
                                 .first,
                        request_page_url: request.xpath('td[@class="title"]/div/a')
                                                 .map{ |link| BITBUCKET_URI + link['href'] }
                                                 .first
                                                 .to_s,
                        author: request.xpath('td[@class="author"]/div/span')
                                       .text)
      end
    end
    list
  end

  private

  def pull_request_list_url(organization_name, project_name)
    "#{BITBUCKET_URI}/#{organization_username}/#{project_name}/pull-requests"
  end
end
