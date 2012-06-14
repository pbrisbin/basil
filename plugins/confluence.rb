Basil.respond_to(/^(confluence|wiki) (.+)/) {

  begin
    xml = get_xml(Basil::Config.confluence.merge(
      'path' => "/rest/prototype/1/search?query=#{escape(@match_data[2])}"))

    result = xml['results']['result']
    result = result.first if result.is_a?(Array)

    says result['link'].first['href']

  rescue
    says 'no results found.'
  end

}.description = 'searches confluence'
