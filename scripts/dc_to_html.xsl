<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace=""
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="xs" version="2.0">

  <xsl:import href="../.xslt/cdrh_to_html/lib/common.xsl"/>
  <xsl:output indent="yes" omit-xml-declaration="yes"/>


  <xsl:param name="site_location"/>
  <xsl:param name="fig_location"/> <!-- set figure location  -->
  <xsl:param name="slug"/>
  <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
    <!-- The part of the url after the main document structure and before the filename. 
    Collected so we can link to files, even if they are nested, i.e. whitmanarchive/manuscripts -->
    
    <!-- Split the filename using '\.' -->
    <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>
    
    <xsl:template match="/">
      <xsl:for-each select="/rdf:RDF/rdf:Description" exclude-result-prefixes="#all">
        <xsl:variable name="filename" select="concat(@about, '.txt')"/>
        <xsl:result-document href="{$filename}">
          <div>
            <img src="{$fig_location}800/{@about}.jpg"/>
            <p><xsl:value-of select="dc:description"/></p>
          </div>
        </xsl:result-document>
      </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
