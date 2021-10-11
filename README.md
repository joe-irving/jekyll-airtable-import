# Jekyll Airtable importer

A simple plugin that used the [Airtable gem](https://rubygems.org/gems/airtable)
create data or collections in Jekyll.

## Installation

Add `gem "jekyll-airtable-import"` to your Jekyll sites Gemfile, under the
plugins group like so:

```ruby
# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-airtable-import"
end
```

## Configuration

To configure your Jekyll site to import from Airtable:

### 1. Add the API key to your environment

Add an environment variable called `AIRTABLE_API_KEY` to all the environments that
your site will be built in.

### 2. Edit your `_config.yml` file

To tell your Jekyll site which tables to import your site from by defining them
in the `airtable` as a list of tables:

```yaml
airtable:
  faqs:  # This key defines the name of the data, in this case it would be available under site.data.faqs
    app: app4ghFya5hfwmfVQ # the base ID for the Airtable
    table: tbl4ghFya5hfwmfVQ # the table that contains your data (in this case faq). Can also be the table name
    view: viw4ghFya5hfwmfVQ # the view that you would like to import. NB this will include hidden fields in the view, but only include records in that view.
  resources:
    app:
    table:
    view:
    combine: true # Combine any existing collections with this data? Defaults to false
  partners:
    app:
    table:
    view:
    fields: # A list of field names that would like to INCLUDE. Important as views do not filter out hidden fields
    - Title
    - URL
    - Image
    - Summary
  # In the below case, "trainings" are a collection - so they can be output as pages etc.
  # To define any of the imports as collections, just add a collection hash
  trainings:
    app:
    table:
    view: 
    fields:
    - Content
    - Title
    - Summary
    - Image
    - Booking link
    - Start Date
    - End date
    collection:
      slug: title # the field title that should be used as the slug. NB the field titles are slugified. E.g. "Start Time" would end up as start_time
      layout: event # the name of a layout that exists in your site's (or your site's theme) _layouts folder
      content: content # the field title that should be used as the conent. NB the field titles are slugified. E.g. "Event Description" would end up as event_description
```

#### Import Fields

Each import's key defines its key in the sites data or collection. Each item in the list of imports has these fields:

| Field | Required? | Notes |
| ----: | :-------: |---|
| app | :heavy_check_mark: | The base ID for the Airtable. Starts with `app` and can be found in an Airtable URL |
| table | :heavy_check_mark: | The table ID or name for the collection/data/  Starts with `tbl` and can be found in an Airtable URL |
| view |  | The view ID  (or name) for the collection/data/  Starts with `viw` and can be found in an Airtable URL |
| fields | | A list of fields found in the headings of Airtable columns, defining the only fields to be imported |
| collection | | If this is defined, the Airtable table will be imported into a collection rather than data. |
| combine | | Define this as truthy for any existing collections to be combined with the imported data. Already is done automatically for data and data, or collections and collections. |


#### Collection feilds

| Field | Required? | Notes |
| ----: | :---------: |---|
| slug | :heavy_check_mark: | the field title that should be used as the slug. NB the field titles are slugified. E.g. "Start Time" would end up as start_time |
| layout | :heavy_check_mark: | the name of a layout that exists in your site's (or your site's theme) _layouts folder |
| content | :heavy_check_mark: | the field title that should be used as the conent. NB the field titles are slugified. E.g. "Event Description" would end up as event_description |

## Collaborations

Fork away :)

## Licence

MIT

## Issues

Just create a pull request :)
