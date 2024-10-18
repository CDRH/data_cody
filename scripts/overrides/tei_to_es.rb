class TeiToEs

  ################
  #    XPATHS    #
  ################

  def override_xpaths
    {
    "citation" => {
      "author" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/author",
      "title_a" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level='a']",
      "title_j" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level='j']",
      "id" => "/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno",
      "publisher" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher"
    },
    "contributor" => [
        "/TEI/teiHeader/fileDesc/titleStmt/respStmt",
        "/TEI/teiHeader/fileDesc/sourceDesc/recordingStmt/recording/respStmt"
    ],
    "creator" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/author",
    "language" => "/TEI/text/body/div1/@lang",
    "notes" => "/TEI/teiHeader/fileDesc/titleStmt/sponsor",
    "person" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term",
    "relation" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/relatedItem/bibl",
    "subcategory" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term",
    "title" => [
      "/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level = 'm']",
      "/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level = 'a']"
    ],
    "title_alt" => "/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']"
    }
  end

  #################
  #    GENERAL    #
  #################

  # do something before pulling fields
  def preprocessing
    # read additional files, alter the @xml, add data structures, etc
  end

  # do something after pulling the fields
  def postprocessing
    # change the resulting @json object here
  end

  # Add more fields
  #  make sure they follow the custom field naming conventions
  #  *_d, *_i, *_k, *_t
  def assemble_collection_specific
  #   @json["fieldname_k"] = some_value_or_method
  end

  ################
  #    FIELDS    #
  ################

  def citation
    cit = []
    author = get_text(@xpaths["citation"]["author"])
    title_a = get_text(@xpaths["citation"]["title_a"])
    title_j = get_text(@xpaths["citation"]["title_j"])
    id = get_text(@xpaths["citation"]["id"])
    publisher = get_text(@xpaths["citation"]["publisher"])

    cit << { 
      "author" => author, 
      "title_a" => title_a, 
      "title_j" => title_j, 
      "id" => id, 
      "publisher" => publisher 
    }
  end

  def contributor
    contribs = get_elements(@xpaths["contributor"]).map do |ele|
      if get_text("name", xml:ele)
        {
          "id" => "",
          "name" => get_text("name", xml: ele),
          "role" => get_text("resp", xml: ele)
        }
      else
        {
          "id" => "",
          "name" => get_text(".", xml: ele),
          "role" => "contributor"
        }
      end
    end
    contribs.uniq
  end

  def cover_image
    images = get_list(@xpaths["image_id"])
    if images && !images.empty?
      images[0]
    else
      sc = category2[0].downcase
      "icon-#{sc}"
    end
  end

  def creator
    #this features a very elaborate process of getting rid of nil values
    creators = []
    creators_check = get_text(@xpaths["creator"])
    if creators_check && !creators_check.empty?
      creators = get_elements(@xpaths["creator"]).map do |ele|
        n_att = get_text("./@n", xml: ele)
        if n_att
          { "name" => n_att }
        else
          { "name" => get_text(".", xml: ele) }
        end
      end

    #rejects key value pairs with nil values from within the hashes
    creators_nonil = []
    creators.each do |i|
      creators_nonil << i.reject { | key, value | value.nil? }
    end

    #rejects empty hashes that may have resulted from the above rejection
    creators_nonil
      .reject { | value | value.empty? }
      .uniq
    end
  end

  def language
    langs = get_list(@xpaths["language"])
    if !langs || langs.empty?
      ["en"]
    else
      langs
    end
  end

  def person
    #this also features a very elaborate process of getting rid of nil values
    people = []
    person_check = get_text(@xpaths["person"])
    if person_check && !person_check.empty?
      people = get_elements(@xpaths["person"]).map do |ele|
        { "name" => get_text(".", xml: ele) }
      end
    end
    people = people.uniq

    #rejects key value pairs with nil values from within the hashes
    people_nonil = []
    people.each do |i|
      people_nonil << i.reject { | key, value | value.nil? }
    end

    #rejects empty hashes that may have resulted from the above rejection
    people_nonil
      .reject { | value | value.empty? }
      .uniq
  end

  def has_relation
    relations = get_elements(@xpaths["relation"]).map do |ele|
      if get_text("title[@type='sub']", xml: ele)
        title = get_text("title[@type='main']", xml: ele) + " | " + get_text("title[@type='sub']", xml: ele)
      else
        title = get_text("title[@type='main']", xml: ele)
      end
      {
        "id" => get_text("idno", xml: ele),
        "title" => title,
        # TODO: this doesn't fit into the schema, but citation is already in use
        "role" => get_text("title[@level='j']", xml: ele),
        "date" => get_text("date", xml: ele)
      }
    end
  end

  def rights_uri
    "http://centerofthewest.org/research/rights-reproductions"
  end

  def text_additional
    text_additional = []
    person = get_text(@xpaths["person"])
    title = get_text(@xpaths["title"])
    author = get_text(@xpaths["citation"]["author"])
    title_a = get_text(@xpaths["citation"]["title_a"])
    title_j = get_text(@xpaths["citation"]["title_j"])
    id = get_text(@xpaths["citation"]["id"])
    publisher = get_text(@xpaths["citation"]["publisher"])
    places = get_text(@xpaths["places"])
    contributor = get_elements(@xpaths["contributor"]).map { |i| get_text("name", xml:i ) }
    creator = get_text(@xpaths["creator"])
    notes = get_text(@xpaths["notes"])
    relation = get_elements(@xpaths["relation"]).map { |i| get_text("title", xml:i) }
    subcategory = get_text(@xpaths["subcategory"])
    
    text_additional << person << title << author << title_a << title_j << id << publisher << places << contributor << creator << notes << relation << subcategory
  end

  def title
    title = get_text(@xpaths["title"])
    if !title || title.empty?
      get_text(@xpaths["title_alt"])
    else
      get_text(@xpaths["title"], delimiter: " |")
    end
  end

end
