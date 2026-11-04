require 'liquid'

module Jekyll
  module MemberFilters
    def member_is_alumni(member)
      data = member_data(member)
      data['status'] == 'alumni' ||
        %w[alumni phd-alumni master-alumni].include?(data['group']) ||
        %w[phd-alumni master-alumni].include?(data['role'])
    end

    def active_members(members)
      Array(members).reject { |member| member_is_alumni(member) }
    end

    def alumni_members(members)
      Array(members).select { |member| member_is_alumni(member) }
    end

    def member_schools(member)
      Array(member_data(member)['schools']).map { |school| school.to_s.strip }.reject(&:empty?).uniq
    end

    def members_by_enrollment(members)
      Array(members).sort_by do |member|
        data = member_data(member)
        year = data['enrollment_year'].to_s
        known_year = year.match?(/\A\d{4}\z/)
        identity = (data['slug'] || data['name']).to_s.downcase
        [known_year ? 0 : 1, known_year ? year.to_i : 0, identity]
      end
    end

    def member_degree(member)
      data = member_data(member)
      %w[degree role group].each do |field|
        degree = data[field].to_s.sub(/-alumni\z/, '')
        label = { 'phd' => '博士', 'master' => '硕士' }[degree]
        return label if label
      end
      nil
    end

    def member_position(member)
      data = member_data(member)
      degree = member_degree(member)
      return "#{degree}毕业生" if member_is_alumni(member) && degree
      data['description']
    end

    def member_academic_details(member)
      data = member_data(member)
      details = []
      details << "#{data['enrollment_year']}年入学" if data['enrollment_year']
      if member_is_alumni(member)
        details << (data['graduation_year'] ? "#{data['graduation_year']}年毕业" : '已毕业')
      elsif data['study_year'] && !data['study_year'].to_s.empty?
        details << data['study_year'].to_s
      end
      details.join(' · ')
    end

    private

    def member_data(member)
      member.respond_to?(:data) ? member.data : member
    end
  end
end

Liquid::Template.register_filter(Jekyll::MemberFilters)
