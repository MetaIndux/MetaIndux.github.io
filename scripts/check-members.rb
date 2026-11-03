require 'jekyll'
require 'nokogiri'

root = Dir.pwd
site = Jekyll::Site.new(Jekyll.configuration('source' => root, 'config' => File.join(root, '_config.yaml'), 'quiet' => true))
site.read
collection = site.collections.fetch('members')

def sample_member(site, collection, slug, values)
  member = Jekyll::Document.new(File.join(site.source, '_members', "#{slug}.md"), site: site, collection: collection)
  member.data.merge!({ 'name' => slug, 'aliases' => [slug], 'affiliation' => 'Beihang University', 'description' => '博士研究生', 'last_modified_at' => nil }.merge(values))
  member.content = ''
  member
end

staff = sample_member(site, collection, 'staff', 'role' => 'professor', 'group' => 'researcher', 'description' => '教授', 'order' => 1)
current = sample_member(site, collection, 'current-doctor', 'role' => 'phd', 'group' => 'phd', 'order' => 2, 'enrollment_year' => 2023, 'study_year' => '博士三年级')
graduate = sample_member(site, collection, 'graduate-doctor', 'role' => 'phd', 'group' => 'phd', 'order' => 3, 'status' => 'alumni', 'enrollment_year' => 2020, 'graduation_year' => 2025, 'study_year' => '博士四年级')
legacy = sample_member(site, collection, 'graduate-master', 'role' => 'master-alumni', 'group' => 'master', 'order' => 4, 'graduation_year' => 2024)
collection.docs.replace([staff, current, graduate, legacy])

filters = Object.new.extend(Jekyll::MemberFilters)
abort 'Active and graduated students must not overlap' unless filters.active_members(collection.docs) == [staff, current] && filters.alumni_members(collection.docs) == [graduate, legacy]
abort 'Legacy alumni groups must still work' unless filters.member_is_alumni({ 'group' => 'phd-alumni' }) && filters.member_is_alumni({ 'group' => 'alumni' })
abort 'Group-only alumni must not retain a student title' unless filters.member_position({ 'group' => 'master-alumni', 'description' => '硕士研究生' }) == '硕士毕业生'
abort 'Graduation must not be inferred from intake year' if filters.member_is_alumni({ 'role' => 'phd', 'enrollment_year' => 2000 })
abort 'Current year must come from the member' unless filters.member_academic_details(current).include?('博士三年级')
abort 'Old study year must not show after graduation' if filters.member_academic_details(graduate).include?('博士四年级')

team = site.pages.find { |page| page.url == '/team/' }
document = Nokogiri::HTML(Jekyll::Renderer.new(site, team).run)
alumni_section = document.at_css('.team-alumni')
abort 'Alumni must be the last team group' unless alumni_section && document.css('.team-portrait-group').last == alumni_section
abort 'Graduates appeared in an active group' unless alumni_section.css('.portrait-name').map { |name| name.text.strip } == %w[graduate-doctor graduate-master]
abort 'Current student disappeared' unless document.css('.team-portrait-group:not(.team-alumni) .portrait-name').map { |name| name.text.strip } == %w[staff current-doctor]

profile = Nokogiri::HTML(Jekyll::Renderer.new(site, graduate).run)
text = profile.at_css('main').text
abort 'Graduated profile has incorrect identity' unless text.include?('博士毕业生') && text.include?('2020年入学') && text.include?('2025年毕业')
abort 'Graduated profile still shows a current study year' if text.include?('博士四年级')
abort 'Profile must have one name heading' unless profile.css('main h1').size == 1
puts 'Verified in memory: year/status display, legacy alumni records, graduates at the bottom and a single-name profile. No sample files were published.'
