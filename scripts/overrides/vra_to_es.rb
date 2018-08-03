class VraToEs

  ################
  #    XPATHS    #
  ################

  def override_xpaths
    xpaths = {}
    xpaths["creator"] = "/vra/work/agentSet/display"
    # cody vra doesn't appear to use anything more specific than the display date
    xpaths["date"] = "/vra/work/dateSet[1]/display"
    xpaths["format"] = "/vra/work[1]/materialSet[1]/display[1]"
    xpaths["title"] = "/vra/work[1]/titleSet[1]/title[1]"
    return xpaths
  end

  ################
  #    FIELDS    #
  ################

  def category
    "images"
  end

  def contributors
    cons = []
    @xml.xpath(@xpaths["contributors"]).each do |contributor|
      crole = contributor.xpath("role").text
      cname = contributor.xpath("name").text
      if crole == "contributor"
        cons << { "name" => cname }
      end
    end
    return cons.empty? ? nil : cons
  end

  def creator
    get_list(@xpaths["creators"]).map do |creator|
      { "name" => creator }
    end
  end

  def date(before=true)
    disp = get_text(@xpaths["date"])
    # strip out anything that's not a "date" character like nums and hyphens
    # (I'm looking at you, "circa")
    no_strings = disp[/([\d-]+)/]
    CommonXml.date_standardize(no_strings, before)
  end

  def date_display
    get_text(@xpaths["date"])
  end

  def image_id
    @id
  end

  def publisher
    pubs = []
    @xml.xpath(@xpaths["publisher"]).each do |publisher|
      prole = publisher.xpath("role").text
      pname = publisher.xpath("name").text
      if prole == "publisher"
        pubs << pname
      end
    end
    pubs.empty? ? nil : pubs
  end

  def rights
    # TODO
  end

  def subcategory
    type = @id[/wfc\.img\.([A-z]+)\./, 1]
    mapping = {
      "cc" => "Cabinet Cards",
      "ill" => "Illustration",
      "pc" => "Postcard",
      "pho" => "Photograph",
      "pst" => "Poster",
      "va" => "Visual Art"
    }
    mapping[type] || "none"
  end

end
