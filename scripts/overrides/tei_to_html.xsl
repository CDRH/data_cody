<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0"
  exclude-result-prefixes="xsl tei xs">

<!-- ==================================================================== -->
<!--                             IMPORTS                                  -->
<!-- ==================================================================== -->

<xsl:import href="../.xslt-datura/tei_to_html/lib/formatting.xsl"/>
<xsl:import href="../.xslt-datura/tei_to_html/lib/personography_encyclopedia.xsl"/>
<!-- <xsl:import href="../.xslt-datura/tei_to_html/lib/cdrh.xsl"/> -->

<!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>


<!-- ==================================================================== -->
<!--                           PARAMETERS                                 -->
<!-- ==================================================================== -->

<xsl:param name="collection"/>
<xsl:param name="data_base"/>
<xsl:param name="environment">production</xsl:param>
<xsl:param name="image_large"/>
<xsl:param name="image_thumb"/>
<xsl:param name="media_base"/>
<xsl:param name="site_url"/>

<!-- ==================================================================== -->
<!--                            OVERRIDES                                 -->
<!-- ==================================================================== -->

  <xsl:template match="ref">
    <!-- the "back" link -->
    <a>
      <xsl:attribute name="name">
        <xsl:value-of select="@target"/>
        <xsl:text>.ref</xsl:text>
      </xsl:attribute>
      <xsl:text> </xsl:text>
    </a>
    <!-- put a target and [1] -->
    <a>
      <xsl:attribute name="href">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="@target"/>
        <xsl:text>.note</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="class">ref</xsl:attribute>
      <xsl:value-of select="text()"/>
    </a>
  </xsl:template>

  <!-- footnotes at the bottom of the page -->
  <xsl:template match="back">
    <xsl:if test="note">
      <div class="bibliography">
        <xsl:for-each select="note">
          <p>
            <a>
              <xsl:attribute name="name">
                <xsl:value-of select="@xml:id"/>
                <xsl:text>.note</xsl:text>
              </xsl:attribute>
              <xsl:text> </xsl:text>
            </a>
            <xsl:apply-templates/>
            <a>
              <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@xml:id"/>
                <xsl:text>.ref</xsl:text>
              </xsl:attribute>
              <xsl:text> [back]</xsl:text>
            </a>
          </p>
        </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- ==================================================================== -->
  <!--                          PERSONOGRAPHY                               -->
  <!-- ==================================================================== -->
  
  <xsl:template name="person_info">
    <div>
      <xsl:attribute name="class">
        <xsl:text>life_item</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
      <h3>
        <a>
          <xsl:attribute name="class">persNameLink</xsl:attribute>
          <!-- construct a search url and rule out the personography as a result, ideally, though that may not be possible -->
          <xsl:attribute name="href"><xsl:value-of select="$site_url"/>/codyarchive/search?f[]=person.name|<xsl:value-of select="encode-for-uri(persName[@type = 'display'])"/></xsl:attribute>
          <xsl:value-of select="persName[@type='display']"/>
        </a>
      </h3>
      <p><xsl:apply-templates select="note"/></p>
    </div>
  </xsl:template>
  
  <!-- ==================================================================== -->
  <!--                           ENCYCLOPEDIA                               -->
  <!-- ==================================================================== -->
  
  <xsl:template name="encyc_info">
    <div>
      <xsl:attribute name="class">
        <xsl:text>life_item</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
      <h3>
        <a>
          <xsl:attribute name="href">
            <!-- construct a search url and use quotation marks on either side of the term, also exclude encyclopedia as a result, ideally -->
            <xsl:value-of select="$site_url"/>/codyarchive/search?q="<xsl:value-of select="head"/>"</xsl:attribute>
          <xsl:value-of select="head"/>
        </a>
      </h3>
      <xsl:apply-templates select="p"/>
    </div>
  </xsl:template>

</xsl:stylesheet>
