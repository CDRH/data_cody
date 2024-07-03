class VraToEs

  ################
  #    XPATHS    #
  ################

  def override_xpaths
    {
    "creator" => "/vra/work/agentSet/display",
    # cody vra doesn't appear to use anything more specific than the display date
    "date" => "/vra/work/dateSet[1]/display",
    "format" => "/vra/work[1]/measurementsSet[1]/display[1]",
    "has_source" => {
      "title" => "/vra/work[1]/sourceSet[1]/display[1]"
      },
    "keywords" => "/vra/work/subjectSet/subject/term[not(@type='personalName')]",
    "person" => "//subjectSet/subject/term[@type='personalName']",
    "publisher" => "/vra/work/agentSet/agent[descendant::name/@type='corporate']",
    "rights_holder" => "/vra/work/rightsSet/rights/rightsHolder",
    "title" => "/vra/work[1]/titleSet[1]/title[1]",
    "topics" => "/vra/work/subjectSet/display[1]"
    }
  end

  ################
  #    FIELDS    #
  ################

  def category
    "Images"
  end

  def category2
    type = @id[/wfc\.img\.([A-z]+)./, 1]
    mapping = {
      "cc" => "Cabinet Cards",
      "ill" => "Illustration",
      "pc" => "Postcard",
      "pho" => "Photograph",
      "pht" => "Photograph",
      "pst" => "Poster",
      "va" => "Visual Art"
    }
    [mapping[type]] || "none"
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

  def has_source
    source = []
    title = get_text(@xpaths["has_source"]["title"])
    if title && !title.empty?
      source << { "title" => title }
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

  def rights_holder
    get_text(@xpaths["rights_holder"])
  end

  def topics
    # may have to add handling for nil here eventually
    t = get_text(@xpaths["topics"])
    if t && !t.empty?
      t_array = t.split(";")
      t_array_s = t_array.collect(&:strip)
    else 
      t_array_s = ""
    end
    t_array_s
  end

  def uri
    # TODO once we understand how the url structure will work for Cody
  end

end
