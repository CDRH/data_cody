class TeiToEs

  ################
  #    XPATHS    #
  ################

  def override_xpaths
    xpaths = {}
    xpaths["creators"] = [
      "/TEI/teiHeader/fileDesc/titleStmt/author",
      "//persName[@type = 'author']",
      "/TEI/teiHeader/fileDesc/sourceDesc/bibl/author/@n"
    ]
    xpaths["language"] = "/TEI/text/body/div1/@lang"
    xpaths["subcategory"] = "/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term"
    xpaths
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

  def image_id
    images = get_list(@xpaths["image_id"])
    if !images.empty?
      images[0]
    else
      sc = subcategory.downcase
      "icon-#{sc}"
    end
  end

  def language
    # take only the FIRST div1 language, as this indicates it is the primary one
    langs = get_list(@xpaths["language"])
    langs.empty? ? "en" : langs[0]
  end

  def languages
    langs = get_list(@xpaths["language"])
    langs.empty? ? ["en"] : langs
  end

  def rights_uri
    "http://centerofthewest.org/research/rights-reproductions"
  end

end
