class TeiToEs

  ################
  #    XPATHS    #
  ################

  def override_xpaths
    {
    "citation" => {
      "author" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/author",
      "title_a" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='a']",
      "title_j" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='j']",
      "id" => "/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno"
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
    ]
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

    # TODO: make this better, yikes
    if title_j && !title_j.empty?
      if title_a && !title_a.empty?
        if author && !author.empty?
          if id && !id.empty?
            cit << { "author" => author, "title_a" => title_a, "title_j" => title_j, "id" => id }
          else
            cit << { "author" => author, "title_a" => title_a, "title_j" => title_j }
          end
        else
          if id && !id.empty?
            cit << { "title_a" => title_a, "title_j" => title_j, "id" => id }
          else
            cit << { "title_a" => title_a, "title_j" => title_j }
          end
        end
      else
        cit << { "title_j" => title_j }
      end
    elsif title_a && !title_a.empty?
      if author && !author.empty?
        cit << { "author" => author, "title_a" => title_a }
      else
        if id && !id.empty?
          cit << { "title_a" => title_a, "id" => id }
        else
          cit << { "title_a" => title_a }
        end
      end
    elsif author && !author.empty?
      if id && !id.empty?
        cit << { "author" => author, "id" => id }
      else
        cit << { "author" => author }
      end
    elsif id && !id.empty?
        cit << { "id" => id }
    end
    #cit << { "author" => author, "title_a" => title_a, "title_j" => title_j, "id" => id }
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
    creators = []
    creators_check = get_text(@xpaths["creator"])
    if creators_check && !creators_check.empty?
      creators = @xml.xpath(@xpaths["creator"])
      creators.map do |c|
        if c["n"]
          { "name" => c["n"] }
        #TODO: this is busted
        elsif c.text && c.text.length > 0
        #else
          { "name" => Datura::Helpers.normalize_space(c.text) }
        end
      end
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
    people = []
    person = get_text(@xpaths["person"])
    if person && !person.empty?
      people = get_elements(@xpaths["person"]).map do |ele|
        {
          "id" => "",
          "name" => get_text(".", xml: ele),
          "role" => ""
        }
      end
    end
    people.uniq
  end

  # using has_relation fields a bit wantonly here--TODO remap or add to schema?
  def has_relation
    relations = get_elements(@xpaths["relation"]).map do |ele|
      {
        #{}"id" => get_text("idno", xml: ele),
        "title" => get_text("title[@type='main']", xml: ele),
        "id" => get_text("title[@type='sub']", xml: ele),
        #{}"title_s" => get_text("title[@type='sub']", xml: ele),
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
    places = get_text(@xpaths["places"])
    
    text_additional << person << title << author << title_a << title_j << places
  end

  def title
    get_text(@xpaths["title"], delimiter: " |")
  end

  def uri
    # TODO once we understand how the url structure will work for Cody
  end

end
