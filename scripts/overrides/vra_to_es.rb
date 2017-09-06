class VraToEs

  ################
  #    XPATHS    #
  ################

  def override_xpaths
    xpaths = {}
    xpaths["dates"] = {
      "earliest" => "/vra/work/dateSet[1]/date[1]/earliestDate[1]",
      # in the original XSL, latest doesn't do anything
      # but I thought I would include it for thoroughness
      # "latest" => "/vra/work/dateSet[1]/date[1]/latestDate[1]",
      "display" => "/vra/work/dateSet[1]/display[1]",
    }
    xpaths["format"] = "/vra/work[1]/materialSet[1]/display[1]"
    xpaths["title"] = "/vra/work[1]/titleSet[1]/title[1]"
    return xpaths
  end

  # NOTE:  Not adding "dateSort_s" equivalent from XSL because
  # I am waiting to see if we will need a different method to sort
  # the field besides the generic date field

  ################
  #    FIELDS    #
  ################

  def category
    return "images"
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
    obj = []
    @xml.xpath(@xpaths["creators"]).each do |creator|
      crole = creator.xpath("role").text
      cname = creator.xpath("name").text
      if !["publisher", "contributor", "creator"].include?(crole)
        if !crole.empty? && !cname.empty?
          obj << { "name" => cname }
        end
      end
    end
    return obj
  end

  def date(before=true)
    early = get_text(@xpaths["dates"]["earliest"])
    disp = get_text(@xpaths["dates"]["display"])

    if !early.empty?
      puts "finding early #{early}"
      return early
    elsif /^\d{4}$/ === disp
      return disp
    # NOTE date could be "unknown" etc in original XSL but
    # that is not possible for the date field type in ES
    else
      return nil
    end
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
    return pubs.empty? ? nil : pubs
  end

  def subcategory
    type = @id[/wfc\.img\.([A-z]+)\./, 1]
    mapping = {
      "cc" => "cabinet_cards",
      "ill" => "illustrations",
      "pc" => "postcards",
      "pho" => "photographs",
      "pst" => "posters",
      "va" => "visual_art"
    }
    return mapping[type] || "none"
  end

end
