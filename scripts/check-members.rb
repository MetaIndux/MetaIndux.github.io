require 'jekyll'
require 'nokogiri'

root = Dir.pwd
site = Jekyll::Site.new(Jekyll.configuration('source' => root, 'config' => File.join(root, '_config.yaml'), 'quiet' => true))
site.read
collection = site.collections.fetch('members')
abort 'Repository-only templates must not enter the member collection' if collection.docs.any? { |member| member.relative_path.include?('/templates/') }
abort 'Repository-only templates must not be copied as static files' if collection.files.any? { |file| file.relative_path.include?('/templates/') }

def sample_member(site, collection, slug, values)
  member = Jekyll::Document.new(File.join(site.source, '_members', "#{slug}.md"), site: site, collection: collection)
  member.data.merge!({ 'name' => slug, 'aliases' => [slug], 'affiliation' => 'Beihang University', 'description' => '博士研究生', 'last_modified_at' => nil }.merge(values))
  member.content = ''
  member
end

staff = sample_member(site, collection, 'staff', 'role' => 'professor', 'group' => 'researcher', 'description' => '教授', 'order' => 1)
staff_later = sample_member(site, collection, 'staff-later', 'role' => 'postdoc', 'group' => 'researcher', 'description' => '博士后', 'order' => 9)
current = sample_member(site, collection, 'current-doctor', 'role' => 'phd', 'group' => 'phd', 'order' => 2, 'enrollment_year' => 2023, 'study_year' => '博士三年级')
earlier = sample_member(site, collection, 'earlier-doctor', 'role' => 'phd', 'group' => 'phd', 'order' => 999, 'enrollment_year' => '2022')
undated = sample_member(site, collection, 'undated-doctor', 'role' => 'phd', 'group' => 'phd', 'order' => 0)
master = sample_member(site, collection, 'current-master', 'role' => 'master', 'group' => 'master', 'description' => '硕士研究生', 'enrollment_year' => 2024)
earlier_master = sample_member(site, collection, 'earlier-master', 'role' => 'master', 'group' => 'master', 'description' => '硕士研究生', 'enrollment_year' => 2023)
graduate = sample_member(site, collection, 'graduate-doctor', 'role' => 'phd', 'group' => 'phd', 'order' => 3, 'status' => 'alumni', 'enrollment_year' => 2020, 'graduation_year' => 2025, 'study_year' => '博士四年级')
legacy = sample_member(site, collection, 'graduate-master', 'role' => 'master-alumni', 'group' => 'master', 'order' => 4, 'enrollment_year' => 2018, 'graduation_year' => 2024)
active = [staff_later, staff, current, undated, earlier, master, earlier_master]
collection.docs.replace(active + [graduate, legacy])

filters = Object.new.extend(Jekyll::MemberFilters)
abort 'Active and graduated students must not overlap' unless filters.active_members(collection.docs) == active && filters.alumni_members(collection.docs) == [graduate, legacy]
abort 'Legacy alumni groups must still work' unless filters.member_is_alumni({ 'group' => 'phd-alumni' }) && filters.member_is_alumni({ 'group' => 'alumni' })
abort 'Group-only alumni must not retain a student title' unless filters.member_position({ 'group' => 'master-alumni', 'description' => '硕士研究生' }) == '硕士毕业生'
abort 'Graduation must not be inferred from intake year' if filters.member_is_alumni({ 'role' => 'phd', 'enrollment_year' => 2000 })
abort 'Current year must come from the member' unless filters.member_academic_details(current).include?('博士三年级')
abort 'Old study year must not show after graduation' if filters.member_academic_details(graduate).include?('博士四年级')

sorting_cases = [
  { 'slug' => 'z-same-year', 'enrollment_year' => '2023', 'order' => 0 },
  { 'slug' => 'z-undated' },
  { 'slug' => 'a-same-year', 'enrollment_year' => 2023, 'order' => 999 },
  { 'slug' => 'a-undated', 'enrollment_year' => '' },
  { 'slug' => 'earliest', 'enrollment_year' => 2020 },
  { 'name' => 'm-undated', 'enrollment_year' => 'unknown' }
]
original_cases = sorting_cases.map(&:dup)
sorted_cases = filters.members_by_enrollment(sorting_cases).map { |member| member['slug'] || member['name'] }
abort 'Enrollment sorting must use year, then filename, with missing years last' unless sorted_cases == %w[earliest a-same-year z-same-year a-undated m-undated z-undated]
abort 'Sorting must not change member data or collection order' unless sorting_cases == original_cases

team = site.pages.find { |page| page.url == '/team/' }
document = Nokogiri::HTML(Jekyll::Renderer.new(site, team).run)
alumni_section = document.at_css('.team-alumni')
abort 'Alumni must be the last team group' unless alumni_section && document.css('.team-portrait-group').last == alumni_section
abort 'Alumni must sort by enrollment year' unless alumni_section.css('.portrait-name').map { |name| name.text.strip } == %w[graduate-master graduate-doctor]
abort 'Staff must keep manual order; students must sort by enrollment year, with undated students last' unless document.css('.team-portrait-group:not(.team-alumni) .portrait-name').map { |name| name.text.strip } == %w[staff staff-later earlier-doctor current-doctor undated-doctor earlier-master current-master]

profile = Nokogiri::HTML(Jekyll::Renderer.new(site, graduate).run)
text = profile.at_css('main').text
abort 'Graduated profile has incorrect identity' unless text.include?('博士毕业生') && text.include?('2020年入学') && text.include?('2025年毕业')
abort 'Graduated profile still shows a current study year' if text.include?('博士四年级')
abort 'Profile must have one name heading' unless profile.css('main h1').size == 1
puts 'Verified in memory: enrollment sorting, unchanged staff order, year/status display, legacy alumni records, graduates at the bottom and a single-name profile. No sample files were published.'
