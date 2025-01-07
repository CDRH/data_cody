class TeiToEsPerson < TeiToEs

  def category
    "Life"
  end

  def get_id
    person = @xml["id"]
    "#{@filename}_#{person}"
  end

  def person
    title_xml = @xml.xpath("persName[@type='display']")
    title = title_xml.text
    people = { "name" => title }
  end

  def category2
    "Personography"
  end

  def text
    text = []
    note = @xml.xpath("note").text
    title_xml = @xml.xpath("persName[@type='display']")
    title = title_xml.text
    text = note + " " + title
  end

  def title
    title_xml = @xml.xpath("persName[@type='display']")
    title = title_xml.text
  end

  def uri
    person = @xml["id"]
    "item/#{@filename}##{person}"
  end

end