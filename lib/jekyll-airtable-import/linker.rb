require 'jekyll'

module Airtable
  module Linker
    class Generator < ::Jekyll::Generator
      priority :low

      def is_lookup(field)
        if field.is_a?(Array) and field.length > 0
          field.each do |item|
            return false unless item[0,3] == "rec"
          end
          return true
        end
        return false
      end

      def lookup_airtable_id(id)
        # lookup = nil
        @conf.each do |name, conf|
          col = @site.collections[name] || nil
          data = @site.data[name] || nil
          if conf['collection'] and col
            matched_record = col.docs.select {|i| i.data['airtable_id'] == id}
            if matched_record.length > 0
              lookup = {
                'type' => 'collection',
                'record' => matched_record,
                'name' => name,
                'collection' => col
              }
              return lookup
            end
          end
          if data and not conf['collection']
            matched_record = data.select {|i| i['airtable_id'] == id}
            if matched_record.length > 0
              lookup = {
                'type' => 'data',
                'record' => matched_record,
                'name' => name,
                'data' => data
              }
              return lookup
            end
          end
        end
        return nil
      end

      def link_record(record)
        record.map do |key, val|
          next unless is_lookup(val)
          Jekyll.logger.debug "Airtable:", "Linker: trying to find match for this id: #{val[0]}, labeled as #{key}"
          match = lookup_airtable_id(val[0])
          next unless match
          Jekyll.logger.debug "Airtable:",  "Linker: matched #{key} with #{match['name']}"
          # puts match.to_yaml
          # new_field = []
          if match['type'] == 'data'
            matched_records = match['data'].select {|i| val.include?(i['airtable_id'])}
          end
          if match['type'] == 'collection'
            matched_records =  match['collection'].docs.select {|i| val.include?(i.data['airtable_id']) }
          end
          # puts matched_records.to_yaml
          # new_field
          record[key] = matched_records
        end
        # puts record.to_yaml
        record
      end

      def generate(site)
        return unless site.config['airtable']
        @site = site
        @conf = site.config['airtable']
        @conf.each do |name, conf|
          Jekyll.logger.debug "Airtable:", "Linking #{name} up"
          data = site.data[name]
          collection = site.collections[name]
          if data
            site.data[name] = data.map { |rec|  link_record(rec)}
          end
          if collection
            collection.docs.each do |doc|
              linked = link_record(doc.data)
              # puts linked
              doc.merge_data!(linked)
            end
          end
        end
      end
    end
  end
end
