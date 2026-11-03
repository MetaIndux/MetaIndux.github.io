load './scripts/submit-indexnow.rb'

origin = 'https://example.org'
unchanged = origin + '/members/unchanged.html'
updated = origin + '/members/updated.html'
added = origin + '/research/new/'
deleted = origin + '/research/deleted/'
before = { unchanged => '<h1>Name</h1><link href="/style.css?v=100">', updated => '<h1>Old name</h1>', deleted => 'Old paper' }
after = { unchanged => '<h1>Name</h1><link href="/style.css?v=200">', updated => '<h1>New name</h1>', added => 'New paper' }
selected = IndexNow.changed_urls(after.keys, before.keys, ->(url) { after.fetch(url) }, ->(url) { before.fetch(url) })
abort 'Change detection must include new, edited and removed pages but ignore build cache versions' unless selected.sort == [updated, added, deleted].sort
abort 'A no-change rebuild must not resubmit URLs' unless IndexNow.changed_urls(after.keys, after.keys, ->(url) { after[url] }, ->(url) { after[url] }).empty?

previous_host_sitemap = '<urlset><url><loc>https://previous.example.org/members/updated.html</loc></url></urlset>'
migration_urls = IndexNow.urls_to_submit(after.keys, previous_host_sitemap, origin,
                                        ->(_url) { abort 'Domain migration must not compare current HTML' },
                                        ->(_url) { abort 'Domain migration must not read old-host HTML' })
abort 'A domain migration must initialize only the new host URLs' unless migration_urls == after.keys
same_host_sitemap = '<urlset><url><loc>https://example.org/members/updated.html</loc></url></urlset>'
same_host_urls = IndexNow.urls_to_submit([updated], same_host_sitemap, origin, ->(_url) { 'same' }, ->(_url) { 'same' })
abort 'Same-host updates must retain incremental submission behavior' unless same_host_urls.empty?

def must_reject(label)
  rejected = false
  begin
    yield
  rescue RuntimeError
    rejected = true
  end
  abort "Expected rejection: #{label}" unless rejected
end

must_reject('another host') { IndexNow.urls_from_sitemap('<urlset><url><loc>https://other.example/page/</loc></url></urlset>', origin) }
must_reject('a query URL') { IndexNow.urls_from_sitemap('<urlset><url><loc>https://example.org/?search=name</loc></url></urlset>', origin) }
must_reject('encoded traversal') { IndexNow.page_path(origin + '/%2e%2e/private', origin) }
abort 'Incorrect root URL mapping' unless IndexNow.page_path(origin + '/', origin) == 'index.html'
abort 'Incorrect member URL mapping' unless IndexNow.page_path(updated, origin) == 'members/updated.html'
abort 'Incorrect publication URL mapping' unless IndexNow.page_path(added, origin) == 'research/new/index.html'

abort '200 must mean receipt, not indexing' unless IndexNow.receipt(200, [updated])[:status] == 'received'
abort '202 must preserve pending key validation' unless IndexNow.receipt(202, [updated])[:status] == 'received_key_validation_pending'
[400, 403, 422, 429, 500].each { |code| must_reject("HTTP #{code}") { IndexNow.receipt(code, [updated]) } }
puts 'Verified IndexNow change detection, URL boundaries and accepted/pending/error responses without contacting a search engine.'
