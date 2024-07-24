class VraToEs

  ################
  #    XPATHS    #
  ################

  def override_xpaths
    {
    "creator" => "/vra/work/agentSet/agent",
    # cody vra doesn't appear to use anything more specific than the display date
    "date" => "/vra/work/dateSet[1]/display",
    "format" => "/vra/work[1]/measurementsSet[1]/display[1]",
    "keywords" => "/vra/work/subjectSet/subject/term[not(@type='personalName')]",
    "person" => "//subjectSet/subject/term[@type='personalName']",
    "publisher" => "/vra/work/agentSet/agent",
    "relation" => "/vra/work/relationSet",
    "rights_holder" => "/vra/work/rightsSet/rights/rightsHolder",
    "source" => "/vra/work/sourceSet",
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

  def contributor
    cons = []
    @xml.xpath(@xpaths["contributor"]).each do |contributor|
      crole = contributor.xpath("role").text
      cname = contributor.xpath("name").text
      if crole == "contributor"
        cons << { "name" => cname }
      end
    end
    cons.empty? ? nil : cons
  end

  def creator
    creators = [] 
    creators_check = get_text(@xpaths["creator"])
    if creators_check && !creators_check.empty?
      @xml.xpath(@xpaths["creator"]).each do |creator|
        crole = creator.xpath("role").text
        cname = creator.xpath("name").text
        if crole == "publisher"
        elsif crole == "contributor"
        else
          creators << { "name" => cname }
        end
      end
      creators.empty? ? nil : creators
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
    #this features a very elaborate process of getting rid of nil values
    source = []
    #not sure source_check is actually doing anything at this point
    source_check = get_text(@xpaths["source"])
    if source_check && !source_check.empty?
      source = get_elements(@xpaths["source"]).map do |ele|
        {
          "title" => get_text("display", xml: ele),
          "id" => get_text("source/name/@href", xml: ele)
        }
      end
    end

    #rejects key value pairs with nil values from within the hashes
    source_nonil = []
    source.each do |i|
      source_nonil << i.reject { | key, value | value.nil? }
    end

    #rejects empty hashes that may have resulted from the above rejection
    source_nonil
      .reject { | value | value.empty? }
  end

  def has_relation
    relations = []
    relations_check = get_text(@xpaths["relation"])
    if relations_check && !relations_check.empty?
      relations = get_elements(@xpaths["relation"]).map do |ele|
        id_full = get_text("relation/@href", xml: ele)
        if id_full.nil?
        elsif id_full.include?("multimedia/")
          id = id_full.sub("multimedia/","")
        elsif
          id = id_full
        end
        {
          "title" => get_text("display", xml: ele),
          "id" => id
        }
      end
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

  def publisher
    pubs = []
    @xml.xpath(@xpaths["publisher"]).each do |publisher|
      prole = publisher.xpath("role").text
      pname = publisher.xpath("name").text
      if prole == "publisher"
        pubs << { "name" => pname }
      end
    end
    pubs.empty? ? nil : cons
  end

  def rights_holder
    get_text(@xpaths["rights_holder"])
  end

  def text_additional
    # why get_text works here when it doesn't for nested elements in tei_to_es, I have no idea
    text_additional = []
    person = get_text(@xpaths["person"])
    creator = get_text(@xpaths["creator"])
    title = get_text(@xpaths["title"])
    places = get_text(@xpaths["places"])
    description = get_text(@xpaths["description"])
    format_m = get_text(@xpaths["format"])
    keywords = get_text(@xpaths["keywords"])
    relation = get_text(@xpaths["relation"])
    rights_holder = get_text(@xpaths["rights_holder"])
    source = get_text(@xpaths["source"])

    text_additional << person << title << creator << places << description << format_m << keywords << relation << rights_holder << source
  end

  def topics
    t = get_text(@xpaths["topics"])
    if t && !t.empty?
      t_array = t.split(";")
      t_array_s = t_array.collect(&:strip)
    else 
      t_array_s = ""
    end
    t_array_s
  end

end
