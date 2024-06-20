class TeiToEs

  ################
  #    XPATHS    #
  ################

  def override_xpaths
    xpaths = {}
    xpaths["creator"] = [
      "/TEI/teiHeader/fileDesc/titleStmt/author",
      "//persName[@type = 'author']",
      "/TEI/teiHeader/fileDesc/sourceDesc/bibl/author/@n"
    ]
    xpaths["language"] = "/TEI/text/body/div1/@lang"
    xpaths["notes"] = "/TEI/teiHeader/fileDesc/titleStmt/sponsor"
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

  def cover_image
    images = get_list(@xpaths["image_id"])
    if images && !images.empty?
      images[0]
    else
      sc = category2[0].downcase
      "icon-#{sc}"
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

  def rights_uri
    "http://centerofthewest.org/research/rights-reproductions"
  end

  def uri
    # TODO once we understand how the url structure will work for Cody
  end

end
