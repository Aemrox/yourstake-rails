require 'csv'

namespace :db_seed do
  desc 'Read the given filename (defaults to company_exclusion.csv) as a csv to populate the companies table'
  task :read_company_exclusion_csv, [:filename] => [:environment] do |t, args|
    args.with_defaults(filename: "task/company_exclusions.csv")
    filename = args.filename

    # Validating the headers of the file
    headers = CSV.open(filename, &:readline)
    attribute_headers = headers.map{|h| h.downcase.tr(" ", "_").to_sym }
    bad_headers = (attribute_headers - Company.column_names.map(&:to_sym))
    raise "BAD HEADERS: #{bad_headers}" unless bad_headers.empty? # Come back and replace this error

    Company.transaction do
      CSV.foreach(filename, headers: true) do |row|
        attrs = row.to_h.transform_keys{|header| header.downcase.tr(" ", "_").to_sym }
        Company.create(attrs)
      end
    end
  end
end