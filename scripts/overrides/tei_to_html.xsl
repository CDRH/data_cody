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
<xsl:param name="environment"/>
<xsl:param name="image_large"/>
<xsl:param name="image_thumb"/>
<xsl:param name="media_base"/>

<!-- ==================================================================== -->
<!--                            OVERRIDES                                 -->
<!-- ==================================================================== -->
  
<!-- ==================================================================== -->
<!--                           LANGUAGE                                   -->
<!-- ==================================================================== --> 
  
  <xsl:template name="language_choice">
    <xsl:param name="language"></xsl:param>
    <xsl:choose>
      <xsl:when test="$language = 'de'">German</xsl:when>
      <xsl:when test="$language = 'en'">English</xsl:when>
      <xsl:when test="$language = 'fr'">French</xsl:when>
      <xsl:when test="$language = 'it'">Italian</xsl:when>
      <xsl:when test="$language = 'es'">Spanish</xsl:when>
      <xsl:when test="$language = 'el'">Greek</xsl:when>
      <xsl:otherwise>Unknown</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="div1[@xml:lang]">
  <div class="translation" id="{@xml:lang}">
    <h4>
      <xsl:choose>
        <xsl:when test="@xml:lang != 'en'">
          <xsl:call-template name="language_choice">
            <xsl:with-param name="language"><xsl:value-of select="@xml:lang"/></xsl:with-param>
          </xsl:call-template>
          <xsl:text> | </xsl:text> 
          <a>
            <xsl:attribute name="href">
              <xsl:text>#en</xsl:text>
            </xsl:attribute>
            <xsl:text>English</xsl:text>
          </a>
        </xsl:when>
        <xsl:when test="not(preceding-sibling::div1)">
          <xsl:text>English</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>English | </xsl:text>
          <a>
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text><xsl:value-of select="preceding-sibling::div1[last()]/@xml:lang"/>
            </xsl:attribute>
            <xsl:call-template name="language_choice">
              <xsl:with-param name="language"><xsl:value-of select="preceding-sibling::div1[last()]/@xml:lang"/></xsl:with-param>
            </xsl:call-template>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </h4>
    <xsl:apply-templates/>
  </div>
  </xsl:template>
  
<!-- ==================================================================== -->
<!--                            NOTES                                     -->
<!-- ==================================================================== -->
  
  <xsl:template match="ref">
    <xsl:choose>
      <!-- When an offsite link -->
      <xsl:when test="starts-with(@target, 'http')">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="@target"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <!-- When an internal link to another document. target should point to full path after siteurl -->
      <xsl:when test="contains(@target, 'wfc')">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="$site_url"/>
            <xsl:value-of select="@target"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="ends-with(@target, 'html')">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="@target"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <!-- otherwise it is a note, and will link to notes in metadat -->
      <xsl:otherwise>
        <a>
          <xsl:attribute name="name">
            <xsl:value-of select="@target"/>
            <xsl:text>.ref</xsl:text>
          </xsl:attribute>
        </a>
        <a>
          <xsl:attribute name="href">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="@target"/>
            <xsl:text>.note</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="class">
            <xsl:text>ref</xsl:text>
          </xsl:attribute> [<xsl:apply-templates/>] </a>
      </xsl:otherwise>
    </xsl:choose>
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
  
  <xsl:template match="body//note">
    <xsl:choose>    
      <xsl:when test="@type='editorial'"/>
      <xsl:when test="@type='editors'"/>
      <xsl:when test="@type='letterhead'">
        <p>
          <xsl:attribute name="class">tei_note_type_letterhead</xsl:attribute>
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:otherwise>
      <p>
        <xsl:attribute name="class">tei_note</xsl:attribute>
        <xsl:apply-templates/>
      </p>
      </xsl:otherwise>
    </xsl:choose>
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
      <xsl:when test="$type = 'audio_illustration'">
        <xsl:variable name="figure_id">
            <xsl:value-of select="graphic/@url"/>
        </xsl:variable>
        <span class="figure">
          <span>
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="$site_url"/>/item/<xsl:value-of select="$figure_id"/>
              </xsl:attribute>
              <img>
                <xsl:attribute name="src">
                  <xsl:call-template name="url_builder">
                    <xsl:with-param name="figure_id_local" select="$figure_id"/>
                    <xsl:with-param name="image_size_local" select="$image_thumb"/>
                    <xsl:with-param name="iiif_path_local" select="$collection"/>
                  </xsl:call-template>
                </xsl:attribute>
                <xsl:attribute name="class">
                  <xsl:text>display&#160;</xsl:text>
                </xsl:attribute>
              </img>
            </a>
          </span>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <div class="inline_figure">
          <div class="tei_figDesc">[<xsl:value-of select="@n"/>]</div>
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
        <xsl:when test="ancestor::div1[@type='audio']">
          <xsl:call-template name="figure_formatter">
            <xsl:with-param name="type">audio_illustration</xsl:with-param>
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
      <source src="{$media_base}/audio/cody_archive/mp3/{@url}" type="audio/mpeg"/>
      <source src="{$media_base}/audio/cody_archive/ogg/{substring-before(@url,'.mp3')}.ogg" type="audio/ogg"/>
    </audio>
  </xsl:template>
  
  <xsl:template match="media[@mimeType='video/mp4']">
    <iframe width="560" height="315" src="{@url}" frameborder="0" allowfullscreen="true">&#160;</iframe>
  </xsl:template>
  
  <!-- ================================================ -->
  <!--              PERSNAME & ORGNAME                  -->
  <!-- ================================================ -->
  
  <xsl:template match="text//persName">
        <a>
          <xsl:attribute name="href">../item/wfc.person#<xsl:value-of select="@xml:id"/></xsl:attribute>
          <xsl:apply-templates/>
        </a>
  </xsl:template>
  
  <xsl:template match="text//orgName">
    <a>
      <xsl:attribute name="href">../item/wfc.encyc#<xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <!-- ================================================ -->
  <!--                 DEL, SUPPLIED                    -->
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
  <!--                 LISTS                            -->
  <!-- ================================================ -->
  
  <!-- this list template (from Whitman) moves anything that's not part of the list into an 
       <li> because html only allows li's inside <ul> or <ol> -->
  <!-- maybe add to datura -->
  <xsl:template match="list">
    <ul>
      <xsl:attribute name="class">
        <xsl:if test="@*">
          <xsl:for-each select="@*">
            <xsl:text>tei_list_</xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>_</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </xsl:if>
        <xsl:text> tei_list</xsl:text>
      </xsl:attribute>
      <xsl:for-each select="./*">
        <li>
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="not(name() = 'item')">
                <xsl:text>non_item tei_list_</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:if test="name() = 'note' and @type = 'authorial'"> tei_list_note_type_authorial</xsl:if>
              </xsl:when>
              <xsl:otherwise><xsl:call-template name="add_attributes"/></xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="."/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  
  <!-- overwrite datura "item" rule since we are adding the <li> tag above -->
  <xsl:template match="item">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- ================================================ -->
  <!--                 TITLE PAGE; MISC ELEMENTS        -->
  <!-- ================================================ -->
  
  <xsl:template match="titlePart | docTitle | docAuthor | docImprint | publisher | pubPlace | quote | address | addrLine | figDesc | stamp">
    <xsl:text> </xsl:text>
    <span>
      <xsl:attribute name="class">tei_<xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="milestone">
    <span>
      <xsl:attribute name="class">tei_<xsl:value-of select="name()"/></xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="fw"/>

</xsl:stylesheet>
