require 'jekyll'
require 'airtable'
require 'active_support/all'

module Airtable
  # Generates Jekyll Collections and Data from Airtable bases.
  #
  # See https://tippingpointuk.github.io/jekyll-airtable-import for more.
  class Generator < ::Jekyll::Generator
    priority :medium

    def parse_airtable_data(data)
      data_parse = []
      data.each do |item|
        # Extract attachments to just their URL
        item.each do |key,val|
          if val.kind_of?(Array)
            if val[0]['url']
              if val.length == 1
                item[key] = val[0]['url']
              else
                item[key] = []
                val.each do | asset |
                  item[key] << asset['url']
                end
              end
            end
          end
        end
        data_parse.push(item)
      end
      data_parse
    end

    def generate(site)
      return unless site.config['airtable']
      # Get API key from environment
      if ENV['AIRTABLE_API_KEY']
        api_key = ENV['AIRTABLE_API_KEY']
      else
        Jekyll.logger.warn "No Airtable api key found. Make sure your key is available as AIRTABLE_API_KEY in the local environment."
        return
      end
      # Pass in api key to client
      @client = Airtable::Client.new(api_key)
      @app_id = nil
      @table_id = nil
      site.config['airtable'].each do |name, conf|
        if conf['app']
          @app_id = conf['app'] # Only update app if conf does
        end
        unless @app_id
          Jekyll.logger.warn "No app ID for Airtable import of " + name
          next
        end
        @table_id = conf['table'] if conf['table']
        unless @table_id
          Jekyll.logger.warn "No table ID for Airtable import of " + name
          next
        end
        # Pass in the app key and table name
        @table = @client.table(@app_id, @table_id)
        # Get records where the Published field is checked
        @records = @table.all(:view => conf['view'],:fields => conf['fields'])
        # Extract data to a hash
        data = @records.map { |record| record.attributes }
        parsed_data = parse_airtable_data(data)
        if conf['collection']
          slug_field = conf['collection']['slug']
          layout = conf['collection']['layout'] || name
          if site.collections[name]
            new_collection = site.collections[name]
          else
            new_collection = Jekyll::Collection.new(site, name)
          end
          parsed_data.each do |item|
            if item[slug_field] and item[slug_field] != ''
              content = item[conf['collection']['content'] || 'content']
              #puts content
              slug = Jekyll::Utils.slugify(item[slug_field])
              path = File.join(site.source, "_#{name}", "#{slug}.md")
              doc = Jekyll::Document.new(path, collection: new_collection, site: site)
              item.merge!({ 'layout' => layout, 'slug' => slug })
              doc.merge_data!(item.except('id'))

              doc.content = content
              new_collection.docs << doc
            end
          end
          site.collections[name] = new_collection
        else
          site.data[name] = data
          if conf['combine'] and site.collections.key?(name)
            site.collections[name].docs.each do |document|
              site.data[name].append(document)
            end
          end
        end
      end
    end
  end
end
