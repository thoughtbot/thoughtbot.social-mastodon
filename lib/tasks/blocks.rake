namespace :blocks do
  desc 'Import a yaml formatted blocklist; see blocklist.yml for example format'
  task :import_yaml, [:filename] => :environment do |task, args|
    domains = YAML.load_file(args[:filename])
    domains.each do |h|
      domain   = h['domain']
      severity = h['severity']

      DomainBlock.where(domain: h['domain'], severity: h['severity'],
                   reject_media: true,  reject_reports: true,
                   public_comment: (h['reason'] + "\n" + (h['link'] || "")),
                   obfuscate: true).
        first_or_create
    end
  end
end
