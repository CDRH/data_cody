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

<xsl:import href="../../../scripts/xslt/cdrh_tei_to_html/lib/html_formatting.xsl"/>
<xsl:import href="../../../scripts/xslt/cdrh_tei_to_html/lib/personography_encyclopedia.xsl"/>
<xsl:import href="../../../scripts/xslt/cdrh_tei_to_html/lib/cdrh.xsl"/>
<!-- If this file is living in a projects directory, the paths will be
     ../../../scripts/xslt/cdrh_tei_to_html/lib/html_formatting.xsl -->

<!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>


<!-- ==================================================================== -->
<!--                           PARAMETERS                                 -->
<!-- ==================================================================== -->

<xsl:param name="figures">true</xsl:param>  <!-- true/false Toggle figures on and off  -->
<xsl:param name="fw">true</xsl:param>       <!-- true/false Toggle fw's on and off  -->
<xsl:param name="pb">true</xsl:param>       <!-- true/false Toggle pb's on and off  -->
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


</xsl:stylesheet>