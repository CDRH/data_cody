<?xml version="1.0"?>
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

<xsl:import href="../../../scripts/xslt/cdrh_to_html/lib/html_formatting.xsl"/>
<xsl:import href="../../../scripts/xslt/cdrh_to_html/lib/personography_encyclopedia.xsl"/>
<xsl:import href="../../../scripts/xslt/cdrh_to_html/lib/cdrh.xsl"/>
<!-- If this file is living in a projects directory, the paths will be
     ../../../scripts/xslt/cdrh_tei_to_html/lib/html_formatting.xsl -->

<!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>


<!-- ==================================================================== -->
<!--                           PARAMETERS                                 -->
<!-- ==================================================================== -->

<xsl:param name="site_url"/>                <!-- the site url (http://codyarchive.org) -->
<xsl:param name="fig_location"></xsl:param> <!-- set figure location  -->

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

  <!-- cody temporarily has a different image path than the other projects, so overriding
  large with 800 and thumbnails with searchresults -->
  <xsl:template match="pb">
    <!-- grab the figure id, first looking in @facs, then @xml:id, and if there is a .jpg, chop it off -->
    <xsl:variable name="figure_id">
      <xsl:variable name="figure_id_full">
        <xsl:choose>
          <xsl:when test="@facs"><xsl:value-of select="@facs"></xsl:value-of></xsl:when>
          <xsl:when test="@xml:id"><xsl:value-of select="@xml:id"></xsl:value-of></xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="contains($figure_id_full,'.jpg')">
          <xsl:value-of select="substring-before($figure_id_full,'.jpg')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$figure_id_full"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <span class="hr">&#160;</span>
    <span>
      <xsl:attribute name="class">
        <xsl:text>pageimage</xsl:text>
      </xsl:attribute>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="$fig_location"/>
          <xsl:text>800/</xsl:text>
          <xsl:value-of select="$figure_id"/>
          <xsl:text>.jpg</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="rel">
          <xsl:text>prettyPhoto[pp_gal]</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:text>&lt;a href="</xsl:text>
          <xsl:value-of select="$fig_location"/>
          <xsl:text>800/</xsl:text>
          <xsl:value-of select="$figure_id"/>
          <xsl:text>.jpg</xsl:text>
          <xsl:text>" target="_blank" &gt;open image in new window&lt;/a&gt;</xsl:text>
        </xsl:attribute>

        <img>
          <xsl:attribute name="src">
            <xsl:value-of select="$fig_location"/>
            <xsl:text>250/</xsl:text>
            <xsl:value-of select="$figure_id"/>
            <xsl:text>.jpg</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="class">
            <xsl:text>display</xsl:text>&#160;
          </xsl:attribute>
        </img>
      </a>
    </span>
  </xsl:template>

</xsl:stylesheet>
