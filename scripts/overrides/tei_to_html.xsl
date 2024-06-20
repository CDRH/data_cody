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
  
  <!-- ================================================ -->
  <!--                   FIGURES                        -->
  <!-- ================================================ -->
  
  <!-- Called via figure template match below -->
  <xsl:template name="figure_formatter">
    <xsl:param name="type"/>
    <xsl:choose>
      <!-- handled by "audio and video" below -->
      <xsl:when test="$type = 'audio' or $type = 'video'"><xsl:apply-templates/></xsl:when>
      <xsl:when test="ancestor::*[name() = 'person']">
        <xsl:apply-templates/>
      </xsl:when>
      <!-- the below isn't currently working: may wish to update to iiif path at some point if feeling ambitious -->
      <xsl:when test="$type = 'illustration'">
        <span class="figure">
          <span>
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="$site_url"/>
                <xsl:text>figures/800/</xsl:text>
                <xsl:value-of select="graphic/@url"/>
                <xsl:text>.jpg</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="rel">
                <xsl:text>prettyPhoto[pp_gal]</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="title">
                <xsl:text>&lt;a href="</xsl:text>
                <xsl:value-of select="$site_url"/>
                <xsl:text>figures/800/</xsl:text>
                <xsl:value-of select="graphic/@url"/>
                <xsl:text>.jpg</xsl:text>
                <xsl:text>" target="_blank" &gt;open image in new window&lt;/a&gt;</xsl:text>
              </xsl:attribute>
              <img>
                <xsl:attribute name="src">
                  <xsl:value-of select="$site_url"/>
                  <xsl:text>figures/250/</xsl:text>
                  <xsl:value-of select="graphic/@url"/>
                  <xsl:text>.jpg</xsl:text>
                </xsl:attribute>
              </img>
            </a>
          </span>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <div class="inline_figure">
          <div class="p">[<xsl:value-of select="@n"/>]</div>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="figure">
    <span class="tei_figure">
      <xsl:choose>
        <xsl:when test="//keywords[@n='category']/term[1] = 'Images'">
          <xsl:call-template name="figure_formatter">
            <xsl:with-param name="type">image</xsl:with-param>
          </xsl:call-template>
        </xsl:when>   
        <xsl:when test="media/@mimeType='audio/mp3'">
          <xsl:call-template name="figure_formatter">
            <xsl:with-param name="type">audio</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="media/@mimeType='video/mp4'">
          <xsl:call-template name="figure_formatter">
            <xsl:with-param name="type">video</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@n='illustration'">
          <xsl:call-template name="figure_formatter">
            <xsl:with-param name="type">other</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="figure_formatter">
            <xsl:with-param name="type">other</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <!--[<xsl:apply-templates/>]-->
    </span>
  </xsl:template>
  
  <xsl:template match="figure//head">
    <h3><xsl:apply-templates/></h3>
  </xsl:template>
  
  <xsl:template match="ab">
    <p>
      <xsl:attribute name="class">
        <xsl:value-of select="name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <!-- ~~~~~~~ audio and video ~~~~~~~ -->
  
  <xsl:template match="media[@mimeType='audio/mp3']">
    <audio controls="controls">
      <source src="{$site_url}audio/mp3/{@url}" type="audio/mpeg"/>
      <source src="{$site_url}audio/ogg/{substring-before(@url,'.mp3')}.ogg" type="audio/ogg"/> 
    </audio>
  </xsl:template>
  
  <xsl:template match="media[@mimeType='video/mp4']">
    <iframe width="560" height="315" src="{@url}" frameborder="0" allowfullscreen="true">&#160;</iframe>
  </xsl:template>

</xsl:stylesheet>
