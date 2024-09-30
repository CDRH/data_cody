class FileTei

  def subdoc_xpaths
    # match subdocs against classes
    {
      "/TEI" => TeiToEs,
      "//body//listPerson/person" => TeiToEsPerson,
    }
  end

  def transform_es
    es_req = []

    begin
      #personography should create entries for each person
      #right now this just avoids output, possibly TODO this could change
      #and be handled like everything else
      #but I am so shocked and overjoyed it is working I am leaving it for now
      if self.filename(false) == "wfc.person"
    	  puts "yay! you are transforming the personography!"
    	  file_xml = parse_markup_lang_file
    	  subdoc_xpaths.each do |xpath, classname|
          	subdocs = file_xml.xpath(xpath)
          	subdocs.each do |subdoc|
            	file_transformer = classname.new(subdoc, @options, file_xml, self.filename(false))
            	es_req << file_transformer.json
          	end
          end
      else
        file_xml = parse_markup_lang_file
        # check if any xpaths hit before continuing
        results = file_xml.xpath(*subdoc_xpaths.keys)
        if results.length == 0
          raise "No possible xpaths found fo file #{self.filename}, check if XML is valid or customize 'subdoc_xpaths' method"
        end
        subdoc_xpaths.each do |xpath, classname|
          subdocs = file_xml.xpath(xpath)
          subdocs.each do |subdoc|
            file_transformer = classname.new(subdoc, @options, file_xml, self.filename(false))
            es_req << file_transformer.json
          end
        end
        if @options["output"]
          filepath = "#{@out_es}/#{self.filename(false)}.json"
          File.open(filepath, "w") { |f| f.write(pretty_json(es_req)) }
        end
      end
      return es_req
    rescue => e
      puts "something went wrong transforming #{self.filename}"
      raise e
    end
  end

end