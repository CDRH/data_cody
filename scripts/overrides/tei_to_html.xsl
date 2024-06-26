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
<xsl:param name="site_url"/>
<xsl:param name="environment">production</xsl:param>
<xsl:param name="image_large"/>
<xsl:param name="image_thumb"/>
<xsl:param name="media_base"/>

<!-- ==================================================================== -->
<!--                            OVERRIDES                                 -->
<!-- ==================================================================== -->
  
<!-- ==================================================================== -->
<!--                            NOTES                                     -->
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
      [<xsl:value-of select="text()"/>]
    </a>
  </xsl:template>

  <!-- notes at the bottom of the page -->
  <xsl:template match="back">
    <xsl:choose>
      <xsl:when test="child::note">
        <div class="bibliography">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:when test="not(child::note) and not(string(.))">
        <xsl:if test="/TEI/teiHeader/fileDesc/notesStmt/note != ''">
          <div class="bibliography">
            <p>Note: <xsl:value-of select="/TEI/teiHeader/fileDesc/notesStmt/note"/></p>
          </div>
        </xsl:if>
      </xsl:when>
      <xsl:when test="string(.)">
        <div class="bibliography">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise/>
      <!-- Do nothing -->
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="//back/note">
    <p>
      <a>
        <xsl:attribute name="name">
          <xsl:value-of select="@xml:id"/>
          <xsl:text>.note</xsl:text>
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </a>
      <xsl:apply-templates/>
      <xsl:text> </xsl:text>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>.ref</xsl:text>
        </xsl:attribute> [back] </a>
    </p>
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
          <xsl:attribute name="href"><xsl:value-of select="$site_url"/>/search?f[]=person.name|<xsl:value-of select="encode-for-uri(persName[@type = 'display'])"/></xsl:attribute>
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
            <xsl:value-of select="$site_url"/>/search?q="<xsl:value-of select="head"/>"</xsl:attribute>
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
        <xsl:attribute name="class">tei_<xsl:value-of select="name()"/><!-- add a class with the name of the element --></xsl:attribute>
        <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <!-- ================================================ -->
  <!--                   AUDIO & VIDEO                  -->
  <!-- ================================================ -->
  
  <xsl:template match="media[@mimeType='audio/mp3']">
    <audio controls="controls">
      <source src="{$site_url}/audio/mp3/{@url}" type="audio/mpeg"/>
      <source src="{$site_url}/audio/ogg/{substring-before(@url,'.mp3')}.ogg" type="audio/ogg"/>
    </audio>
  </xsl:template>
  
  <xsl:template match="media[@mimeType='video/mp4']">
    <iframe width="560" height="315" src="{@url}" frameborder="0" allowfullscreen="true">&#160;</iframe>
  </xsl:template>
  
  <!-- ================================================ -->
  <!--                   PERSNAME                       -->
  <!-- ================================================ -->
  
  <xsl:template match="text//persName">
        <a>
          <xsl:attribute name="href"><xsl:value-of select="$site_url"/>/item/wfc.person#<xsl:value-of select="@xml:id"/></xsl:attribute>
          <xsl:apply-templates/>
        </a>
  </xsl:template>

  <!-- ================================================ -->
  <!--                 DEL, SUPPLIED               -->
  <!-- ================================================ -->
   
  <xsl:template match="del">
    <xsl:text> </xsl:text>
    <span>
      <xsl:attribute name="class">tei_<xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="supplied">
    <xsl:text> </xsl:text>
    <span>
      <xsl:attribute name="class">tei_<xsl:value-of select="name()"/></xsl:attribute>
      [<xsl:apply-templates/>]
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <!-- ================================================ -->
  <!--                 TITLE PAGE; MISC ELEMENTS        -->
  <!-- ================================================ -->
  
  <xsl:template match="titlePart | docTitle | docAuthor | docImprint | publisher | pubPlace | quote | address | addrLine | figDesc">
    <xsl:text> </xsl:text>
    <span>
      <xsl:attribute name="class">tei_<xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

</xsl:stylesheet>
