require 'jekyll'

module Airtable
  module Linker
    class Generator < ::Jekyll::Generator
      priority :low

      def is_lookup(field)
        if field.is_a?(Array)
          field.each do |item|
            return false unless item[0,3] == "rec"
          end
          return true
        end
        return false
      end
      def link_record(record)
        # puts record
        record.map do |key, val|
          next unless is_lookup(val)
          match_data = @site.data[key] || nil
          match_collection = @site.collections[key] || nil
          # puts record.to_yaml
          # puts match_collection.to_yaml
          next unless ( match_data or match_collection )
          new_field = []
          # puts val
          val.each do |id|
            if match_data
              matched_record = match_data.select {|i| i['id'] == id}
            end
            if match_collection.is_a?(Jekyll::Collection)
              matched_record ||= match_collection.docs.select {|i| i.data['id'] == id}
            end
            if key == "posts"
              # puts matched_record.to_yaml
              # puts matched_record[0].url
            end

            if matched_record
              new_field << matched_record[0]
            end
          end
          record[key] = new_field
          # puts new_field
        end
        # puts record.to_yaml
        record
      end
      def generate(site)
        return unless site.config['airtable']
        @site = site
        @conf = site.config['airtable']
        @conf.each do |name, conf|
          puts name
          data = site.data[name]
          collection = site.collections[name]
          if data
            site.data[name] = data.map { |rec|  link_record(rec)}
          end
          if collection
            new_collection = site.collections[name]
            collection.docs.each do |doc|
               doc.merge_data!(link_record(doc.data))
               # puts doc.data.to_yaml
               # site.collections[name].docs << doc
            end
            puts site.collections[name].class
          end
        end
      end
    end
  end
end
