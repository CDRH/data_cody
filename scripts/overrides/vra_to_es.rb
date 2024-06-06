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
    xpaths
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
    cons.empty? ? nil : cons
  end

  def creator
    creators = get_list(@xpaths["creator"])
    if creators
      creators.map do |creator|
        { "name" => creator }
      end
    end
  end

  def date(before=true)
    disp = get_text(@xpaths["date"])
    # strip out anything that's not a "date" character like nums and hyphens
    # (I'm looking at you, "circa")
    if disp
      no_strings = disp[/([\d-]+)/]
      Datura::Helpers.date_standardize(no_strings, before)
    end
  end

  def date_display
    get_text(@xpaths["date"])
  end

  def cover_image
    @id
  end

  def citation
    pubs = []
    @xml.xpath(@xpaths["publisher"]).each do |publisher|
      prole = publisher.xpath("role").text
      pname = publisher.xpath("name").text
      if prole == "publisher"
        pubs << {
          "publisher" => pname
      }
      end
    end
    pubs.empty? ? nil : pubs
  end

  def rights
    # TODO
  end

  def category2
    type = @id[/wfc\.img\.([A-z]+)\./, 1]
    mapping = {
      "cc" => "Cabinet Cards",
      "ill" => "Illustration",
      "pc" => "Postcard",
      "pho" => "Photograph",
      "pst" => "Poster",
      "va" => "Visual Art"
    }
    [mapping[type]] || "none"
  end

  def uri
    # TODO once we understand how the url structure will work for Cody
  end

end
