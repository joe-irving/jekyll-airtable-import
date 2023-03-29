require 'jekyll'
require 'airtable'
require 'active_support/all'
require 'open-uri'
require 'dotenv/load'
require 'jekyll-airtable-import/linker'

module Airtable
  # Generates Jekyll::Collection s and Data from Airtable bases.
  #
  # See https://tippingpointuk.github.io/jekyll-airtable-import for more.
  class Generator < ::Jekyll::Generator
    priority :medium

    def download_attachment(at_attachment)
      ext = ".#{at_attachment['type'].split('/')[-1]}" if at_attachment['type'].is_a? String
      ext ||= ''
      file_name = "#{at_attachment['filename']}#{ext}"
      
      Dir.mkdir "#{Dir.pwd}/assets" unless Dir.exists? "#{Dir.pwd}/assets"
      assets_dir = Dir.mkdir "#{Dir.pwd}/assets/airtable" unless Dir.exists? "#{Dir.pwd}/assets/airtable"
      new_path = "#{Dir.pwd}/assets/airtable/#{file_name}"
      return "/assets/airtable/#{file_name}" if File.exists? new_path

      attachment = URI.open(at_attachment['url'])
      IO.copy_stream(attachment, new_path)
      new_file = Jekyll::StaticFile.new(@site, @site.source, '/assets/airtable/', file_name)
      @site.static_files << new_file

      new_file.url
    end

    def parse_airtable_data(data)
      data_parse = []
      data.each do |item|
        # Extract attachments to just their URL
        item.each do |key,val|
          if val.kind_of?(Array)
            if val[0]['url']
              if val.length == 1
                item[key] = download_attachment(val[0])
              else
                item[key] = []
                val.each do | asset |
                  item[key] << download_attachment(asset)
                end
              end
            end
          end
        end
        item['airtable_id'] = item['id']
        data_parse.push(item)
      end

      data_parse
    end

    def generate(site)
      @site = site
      @log_name = "Airtable:"
      return unless site.config['airtable']

      @site = site
      # Get API key from environment
      if ENV['AIRTABLE_API_KEY']
        api_key = ENV['AIRTABLE_API_KEY']
      else
        Jekyll.logger.warn @log_name, "No API key found. Make sure your key is available as AIRTABLE_API_KEY in the local environment => Ruby ENV hash."
        return
      end
      # Pass in api key to client
      @client = Airtable::Client.new(api_key)
      @app_id = nil
      @table_id = nil
      site.config['airtable'].each do |name, conf|
        conf ||= Hash.new
        if conf['app']
          # Only update app if conf does
          @app_id = conf['app'][0..3] == 'ENV_' ? ENV[conf['app'][4..-1]] : conf['app']
        end
        unless @app_id
          Jekyll.logger.warn @log_name, "No app ID for Airtable import of #{name}"
          next
        end
        if conf['table']
          @table_id = conf['table'][0..3] == 'ENV_' ? ENV[conf['table'][4..-1]] : conf['table']
        end
        unless @table_id
          Jekyll.logger.warn @log_name, "No table ID for Airtable import of #{name}"
          next
        end
        Jekyll.logger.debug @log_name, "Importing #{name} from https://airtable.com/#{@app_id}/#{@table_id}/#{conf['view']}"
        # Pass in the app key and table name
        @table = @client.table(@app_id, @table_id)
        # Get records where the Published field is checked
        @records = @table.all(:view => conf['view'],:fields => conf['fields'])
        Jekyll.logger.debug @log_name, "Found #{@records.length} records to import for #{name}"
        # Extract data to a hash
        data = @records.map { |record| record.attributes }
        # puts data
        parsed_data = parse_airtable_data(data)
        if conf['collection']
          if conf['collection'].is_a?(Hash)
            collection_conf = conf['collection']
          end
          collection_conf ||= Hash.new
          content_field = collection_conf['content'] || 'content'
          slug_fields = [collection_conf['slug'] || "slug", "slug", "title","name"]
          layout = collection_conf['layout'] || name.singularize
          if site.collections[name]
            new_collection = site.collections[name]
          else
            new_collection = Jekyll::Collection.new(site, name)
          end
          parsed_data.each_with_index do |item, index|
            content = item[conf['collection']['content'] || 'content'] if conf['collection'].is_a?(Hash)
            #puts content
            for slug_field in slug_fields
              if item[slug_field] and !item[slug_field].is_a?(Array)
                slug = Jekyll::Utils.slugify(item[slug_field])
                break
              end
            end
            slug ||= Jekyll::Utils.slugify("#{name}#{index}")
            path = File.join(site.source, "_#{name}", "#{slug}.md")
            doc = Jekyll::Document.new(path, collection: new_collection, site: site)
            item.merge!({
              'layout' => layout,
              'slug' => slug,
              'airtable_id' => item['id']
            })
            doc.merge_data!(item.except('id'))

            doc.content = content
            new_collection.docs << doc
          end
          site.collections[name] = new_collection
        else
          site.data[name] = data
          ## Combine existing collections (of the same name) into the imported data
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
