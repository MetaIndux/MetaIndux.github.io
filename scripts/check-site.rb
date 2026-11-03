require 'date'
require 'json'
require 'nokogiri'
require 'uri'
require 'yaml'

root = Dir.pwd
load File.join(root, '_plugins/members.rb')
member_filters = Object.new.extend(Jekyll::MemberFilters)
destination = File.expand_path(ARGV.fetch(0, '_site'), root)
config = YAML.load_file(File.join(root, '_config.yaml'))
origin = config.fetch('url') + config.fetch('baseurl', '')
failures = []
check = ->(condition, message) { failures << message unless condition }
read_page = ->(path) { Nokogiri::HTML(File.read(File.join(destination, path), encoding: 'UTF-8')) }
sitemap = Nokogiri::XML(File.read(File.join(destination, 'sitemap.xml')))
locations = sitemap.xpath('//*[local-name()="loc"]').map(&:text)
team = read_page.call('team/index.html')
titles = []

Dir.glob(File.join(root, '_members', '*.md')).each do |source|
  member = YAML.safe_load(File.read(source, encoding: 'UTF-8').split(/^---\s*$\n?/)[1])
  slug = File.basename(source, '.md')
  route = "/members/#{slug}.html"
  document = read_page.call(route.delete_prefix('/'))
  name = member.fetch('name')
  main = document.at_css('main')&.text.to_s
  title = document.at_css('title')&.text.to_s
  description = document.at_css('meta[name="description"]')&.[]('content').to_s
  canonical = document.css('link[rel="canonical"]')
  expected_url = origin + route

  check.call(document.at_css('html')&.[]('lang') == 'zh-CN', "#{slug}: wrong language")
  check.call(document.css('main h1').size == 1 && document.at_css('main h1').text.include?(name), "#{slug}: missing name heading")
  check.call(main.include?(member_filters.member_position(member)) && main.include?(member.fetch('affiliation')), "#{slug}: missing visible identity")
  %w[enrollment_year graduation_year].each do |field|
    check.call(member[field].to_s.match?(/\A\d{4}\z/), "#{slug}: invalid #{field}") if member[field]
  end
  if member['graduation_year']
    check.call(member_filters.member_is_alumni(member), "#{slug}: graduation year requires alumni status")
  end
  Array(member['aliases']).each { |alias_name| check.call(main.include?(alias_name), "#{slug}: missing English name") }
  check.call(title.include?(name) && description.include?(name) && description.include?(config.fetch('title')), "#{slug}: incomplete metadata")
  if member['affiliation'] == 'Beihang University'
    check.call(title.include?("北航#{name}") && main.include?('北航') && main.include?('北京航空航天大学'), "#{slug}: missing Beihang name association")
  end
  check.call(canonical.size == 1 && canonical.first['href'] == expected_url, "#{slug}: incorrect canonical")
  check.call(document.at_css('meta[property="og:url"]')&.[]('content') == expected_url, "#{slug}: incorrect social URL")
  check.call(!document.at_css('meta[name="robots"]')&.[]('content').to_s.include?('noindex'), "#{slug}: indexing blocked")
  check.call(locations.include?(expected_url), "#{slug}: absent from sitemap")
  check.call(team.css('a[href]').any? { |link| link['href'] == config.fetch('baseurl', '') + route }, "#{slug}: missing team link")
  submission_link = document.at_css('.member-submission-actions .button')
  if submission_link
    submission_uri = URI(submission_link['href'])
    submission_query = URI.decode_www_form(submission_uri.query.to_s).to_h
    check.call(submission_uri.host == 'github.com' && submission_uri.path == "/#{config.fetch('repository')}/issues/new", "#{slug}: incorrect submission destination")
    check.call(submission_query['template'] == 'member-profile.yml' && submission_query['member_name'] == name && submission_query['member_page'] == expected_url, "#{slug}: incorrect profile submission prefill")
  else
    check.call(false, "#{slug}: missing profile submission entry")
  end

  structured = document.css('script[type="application/ld+json"]').map { |script| JSON.parse(script.text) }
  profile = structured.find { |item| item['@type'] == 'ProfilePage' }
  check.call(profile && profile.dig('mainEntity', '@type') == 'Person' && profile.dig('mainEntity', 'name') == name && profile['url'] == expected_url, "#{slug}: incorrect person schema")
  document.css('main img[src]').each do |img|
    image_path = URI::DEFAULT_PARSER.unescape(img['src']).delete_prefix(config.fetch('baseurl', '')).delete_prefix('/')
    check.call(File.file?(File.join(destination, image_path)), "#{slug}: missing portrait #{image_path}")
  end
  titles << title
end

check.call(titles.uniq.size == titles.size, 'Member page titles are not unique')
locations.each do |location|
  check.call(location.start_with?(origin + '/'), "Non-production sitemap URL: #{location}")
end
%w[index.html team/index.html research/index.html team/submit/index.html].each do |path|
  document = read_page.call(path)
  expected = origin + '/' + path.delete_suffix('index.html')
  check.call(document.at_css('link[rel="canonical"]')&.[]('href') == expected, "#{path}: incorrect canonical")
  document.css('script[type="application/ld+json"]').each { |script| JSON.parse(script.text) }
end

submission_page = read_page.call('team/submit/index.html')
check.call(locations.include?(origin + '/team/submit/'), 'Profile submission guide absent from sitemap')
check.call(team.css('a[href]').any? { |link| link['href'] == config.fetch('baseurl', '') + '/team/submit/' }, 'Team page is missing its submission entry')
check.call(submission_page.css('a[href]').any? { |link| link['href'] == "https://github.com/#{config.fetch('repository')}/issues/new?template=member-profile.yml" }, 'Submission guide has an incorrect form link')
download_path = 'downloads/member-profile-template.md'
check.call(File.file?(File.join(destination, download_path)), 'Member introduction template is not downloadable')
check.call(submission_page.css('a[download]').any? { |link| link['href'] == config.fetch('baseurl', '') + '/' + download_path }, 'Submission guide is missing the template download')
member_form = YAML.load_file(File.join(root, '.github/ISSUE_TEMPLATE/member-profile.yml'))
form_fields = member_form.fetch('body').reject { |field| field['type'] == 'markdown' }
field_ids = form_fields.map { |field| field.fetch('id') }
check.call(field_ids.uniq.size == field_ids.size, 'Member form field identifiers are not unique')
%w[member_name english_name member_page position student_status degree_stage enrollment_year study_year graduation_year biography research_interests selected_work public_contact portrait publication_confirmation].each do |field_id|
  check.call(field_ids.include?(field_id), "Member form missing #{field_id}")
end
portrait_field = form_fields.find { |field| field['id'] == 'portrait' }
check.call(portrait_field['type'] == 'textarea' && !portrait_field.fetch('attributes').key?('render'), 'Photo textarea must support GitHub attachment upload')
check.call(File.read(File.join(destination, 'robots.txt')).include?("Sitemap: #{origin}/sitemap.xml"), 'Missing robots sitemap URL')
check.call(!locations.include?(origin + '/404.html'), '404 must not appear in sitemap')
check.call(!File.exist?(File.join(destination, 'tmp')), 'Temporary research files must not be published')
if config['indexnow']
  key_file = config.fetch('indexnow').fetch('key_file')
  check.call(File.read(File.join(destination, key_file), encoding: 'UTF-8').strip == key_file.delete_suffix('.txt'), 'Published IndexNow ownership proof is invalid')
end

details = YAML.load_file(File.join(root, '_data/publication_details.yaml'))
citations = YAML.load_file(File.join(root, '_data/citations.yaml'))
research = read_page.call('research/index.html')
homepage = read_page.call('index.html')
check.call(homepage.css('main h1').size == 1 && homepage.at_css('main h1').text.include?('北航任磊'), 'Homepage must identify the research group')
details.each do |detail|
  slug = detail.fetch('slug')
  citation = citations.find { |record| record['doi'].to_s.downcase == detail.fetch('doi').downcase }
  route = "/research/#{slug}/"
  expected_url = origin + route
  document = read_page.call("research/#{slug}/index.html")
  check.call(document.at_css('main h1')&.text == citation.fetch('title'), "#{slug}: incorrect paper title")
  check.call(document.at_css('main')&.text.include?(detail.fetch('summary')), "#{slug}: missing research description")
  check.call(document.at_css('link[rel="canonical"]')&.[]('href') == expected_url, "#{slug}: incorrect paper canonical")
  check.call(document.at_css('meta[property="og:url"]')&.[]('content') == expected_url, "#{slug}: incorrect paper social URL")
  check.call(document.at_css('meta[name="citation_doi"]')&.[]('content') == citation['doi'], "#{slug}: incorrect citation DOI")
  check.call(document.css('meta[name="citation_author"]').map { |node| node['content'] } == citation['authors'], "#{slug}: incomplete or reordered authors")
  check.call(locations.include?(expected_url), "#{slug}: paper absent from sitemap")
  check.call(research.css('a[href]').any? { |link| link['href'] == config.fetch('baseurl', '') + route }, "#{slug}: paper absent from research links")
  graph = JSON.parse(document.at_css('script[type="application/ld+json"]').text)
  check.call(graph.dig('mainEntity', '@type') == 'ScholarlyArticle' && graph.dig('mainEntity', 'identifier', 'value') == citation['doi'], "#{slug}: invalid paper schema")
  detail.fetch('sources').each do |source|
    check.call(document.css('main a[href]').any? { |link| link['href'] == source.fetch('url') }, "#{slug}: missing source attribution")
  end
  document.css('main a[href^="/"]').each do |link|
    path = URI::DEFAULT_PARSER.unescape(link['href']).delete_prefix(config.fetch('baseurl', '')).delete_prefix('/')
    path += 'index.html' if path.empty? || path.end_with?('/')
    check.call(File.file?(File.join(destination, path)), "#{slug}: broken internal link #{link['href']}")
  end
end

abort(failures.join("\n")) unless failures.empty?
puts "Verified #{titles.size} member pages: visible names, portraits, canonical URLs, JSON-LD, team links and sitemap."
puts "Verified #{details.size} publication pages: sourced descriptions, complete authors, citation metadata and crawlable links."
