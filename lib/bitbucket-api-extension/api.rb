# coding: utf-8

module BitbucketApiExtension; end

class BitbucketApiExtension::Api

  BITBUCKET_URI = 'https://bitbucket.org'
  BITBUCKET_API_URI = 'https://api.bitbucket.org/1.0/repositories'

  attr_reader :account, :project

  def initialize(project, account=nil)
    @project = project
    @account = account
  end

  # プルリクエスト一覧を取得する
  def pull_requests
    uri = pull_request_list_url(@project.organization_name, @project.name)
    list = []
    open(uri, auth_option) do |f|
      html = Nokogiri::HTML(f.read).xpath('//table[contains(@class,"pullrequest-list")]/tbody/tr')
      list = html.map do |request|
        title = request.xpath('td[@class="title"]/div/a').text
        BitbucketApiExtension::PullRequest.new(
          title: title,
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

  # プルリクエストの詳細情報を取得する
  def pull_request_detail(pull_request)
    detail = BitbucketApiExtension::PullRequestDetail.new(pull_request.attributes)
    open(pull_request.request_page_url, auth_option) do |f|
      html = Nokogiri::HTML(f.read)
      p "---"
      commands = html.xpath('//pre[@class="merge-commands"]/code').text.split("\n")
    end
    detail
  end

  # 指定したプルリクエストのマージコマンドを取得する
  def merge_commands(pull_request)
    commands = []
    open(pull_request.request_page_url, auth_option) do |f|
      html = Nokogiri::HTML(f.read)
      commands = html.xpath('//pre[@class="merge-commands"]/code').text.split("\n")
    end
    commands
  end

  # 指定したプルリクエストに関連するコメントを取得する
  def pull_request_comment(pull_request)
    url = pull_request_comment_url(@project.organization_name, @project.name, pull_request.id)
    comment = []
    open(url, auth_option) do |f|
      list = JSON.parse(f.read)
      comment = list.map do |c|
        BitbucketApiExtension::Comment.new(
          pull_request_id: c["pull_request_id"],
          author_username: c["author_info"]["username"],
          author_display_name: c["author_info"]["display_name"],
          comment: c["content"])
      end
    end
    comment
  end

  # 指定したプルリクエストにコメントを書き込む
  def post_comment(pull_request, text)
    url = pull_request_comment_url(@project.organization_name, @project.name, pull_request.id)
    post(url, content: text)
  end

  private

  def auth_option
    if @account.nil?
      {}
    else
      {http_basic_authentication: [@account.user_id, @account.user_password]}
    end
  end

  def pull_request_list_url(organization_name, project_name)
    "#{BITBUCKET_URI}/#{organization_name}/#{project_name}/pull-requests"
  end

  def pull_request_comment_url(organization_name, project_name, id)
    "#{BITBUCKET_API_URI}/#{organization_name}/#{project_name}/pullrequests/#{id}/comments"
  end

  def post(uri, body)
    uri = URI.parse(uri)
    request = Net::HTTP::Post.new(uri.path)
    request.basic_auth(@account.user_id, @account.user_password)
    request.set_form_data(body)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.start { |h| h.request(request) }
  end
end
