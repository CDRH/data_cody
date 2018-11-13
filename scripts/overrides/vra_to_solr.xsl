<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:vra="http://www.vraweb.org/vracore4.htm"
  xpath-default-namespace="http://www.vraweb.org/vracore4.htm"
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- ==================================================================== -->
  <!--                               IMPORTS                                -->
  <!-- ==================================================================== -->

  <xsl:import href="../.xslt/common.xsl"/>
  <xsl:import href="../.xslt/vra_to_solr/lib/fields.xsl"/>
  <!-- If this file is living in a collections directory, the paths will be
       ../../../scripts/xslt/cdrh_to_solr/lib/common.xsl -->

  <xsl:output indent="yes" omit-xml-declaration="yes"/>

  <!-- ==================================================================== -->
  <!--                           PARAMETERS                                 -->
  <!-- ==================================================================== -->

  <xsl:param name="collection"/>
  <xsl:param name="data_base"/>
  <xsl:param name="environment">production</xsl:param>
  <xsl:param name="media_base"/>
  <xsl:param name="slug"/>          <!-- slug of collection -->
  <xsl:param name="site_url"/>



  <!-- ==================================================================== -->
  <!--                            OVERRIDES                                 -->
  <!-- ==================================================================== -->


  <!-- choosing dates from VRA files. This needs some work -->
  <xsl:variable name="vra_date">
    <xsl:choose>
      <!-- exact date -->
      <xsl:when test="/vra/work/dateSet/date/earliestDate and not(/vra/work/dateSet/date/latestDate)">
        <xsl:value-of select="/vra/work/dateSet/date[1]/earliestDate[1]"/>
      </xsl:when>
      <!-- circa date, taking the earliest right now but could change -->
      <xsl:when test="/vra/work/dateSet/date/earliestDate and /vra/work/dateSet/date/latestDate">
        <xsl:value-of select="/vra/work/dateSet/date[1]/earliestDate[1]"/>
      </xsl:when>
      <xsl:when test="starts-with(/vra/work[1]/dateSet[1]/display[1],'1')">
        <xsl:value-of select="/vra/work[1]/dateSet[1]/display[1]"/>
      </xsl:when>
      <xsl:when test="/vra/work/dateSet/date[1]/earliestDate[1] = ''">
        <xsl:text>undated</xsl:text>
      </xsl:when>
      <xsl:when test="contains(/vra/work/dateSet[1]/display[1],'circa')">
        <xsl:value-of select="substring(/vra/work/dateSet[1]/display[1],7,4)"/>
      </xsl:when>
      <xsl:otherwise>unknown</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- taking filename/id for now -->
  <xsl:template name="image_id">
    <field name="image_id">
      <xsl:value-of select="/vra/work[1]/@id"/>
    </field>
  </xsl:template>

  <xsl:template name="format">
    <field name="format">
      <xsl:value-of select="/vra/work[1]/materialSet[1]/display[1]"></xsl:value-of>
    </field>
  </xsl:template>

  <xsl:template name="creators">
    <!-- I don't love the way I am doing this but it works so leaving for now -->
    <xsl:variable name="creator_check">
      <xsl:for-each select="//work/agentSet/agent">
        <xsl:choose>
          <xsl:when test="role='publisher'"></xsl:when>
          <xsl:when test="role='contributor'"></xsl:when>
          <xsl:when test="role!=''">creator</xsl:when>
          <xsl:when test="role='' and name != ''">creator</xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <!-- Creator -->
    <xsl:if test="contains($creator_check,'creator')">
      <field name="creator">
        <xsl:for-each select="/vra/work/agentSet/agent">
          <xsl:if test="role != 'publisher' and role != 'contributor' and normalize-space(.) != ''">
            <xsl:value-of select="normalize-space(name)"/>
            <xsl:if test="position() != last()">
              <xsl:text>; </xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </field>
    </xsl:if>
  </xsl:template>

  <xsl:template name="publisher">

    <xsl:for-each select="/vra/work/agentSet/agent">
      <xsl:if test="role = 'publisher'">
        <field name="publisher">
          <xsl:value-of select="name"/>
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="contributors">

    <xsl:for-each select="/vra/work/agentSet/agent">
      <xsl:if test="role = 'contributor'">
        <field name="contributor">
          <xsl:value-of select="name"/>
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <!-- master tamplate does not handle keywords, when it does, overwrite here instead of in extras -->
  <!--<xsl:template name="keywords"></xsl:template>-->

  <xsl:template name="category">
    <field name="category">
      <xsl:text>Images</xsl:text>
    </field>
  </xsl:template>

  <!-- setting subCategory by filename -->
  <xsl:template name="subCategory">
    <field name="subCategory">
      <xsl:variable name="filename" select="tokenize(document-uri(/), '/')[last()]" />
      <xsl:choose>
        <xsl:when test="contains($filename, '.pho')">
          <xsl:text>photographs</xsl:text>
        </xsl:when>
        <xsl:when test="contains($filename, '.pht')">
          <xsl:text>photographs</xsl:text>
        </xsl:when>
        <xsl:when test="contains($filename, '.pc')">
          <xsl:text>postcards</xsl:text>
        </xsl:when>
        <xsl:when test="contains($filename, '.pst')">
          <xsl:text>posters</xsl:text>
        </xsl:when>
        <xsl:when test="contains($filename, '.ill')">
          <xsl:text>illustrations</xsl:text>
        </xsl:when>
        <xsl:when test="contains($filename, '.va')">
          <xsl:text>visual_art</xsl:text>
        </xsl:when>
        <xsl:when test="contains($filename, '.cc')">
          <xsl:text>cabinet_cards</xsl:text>
        </xsl:when>
      </xsl:choose>
    </field>
  </xsl:template>


  <!-- DATES -->
  <xsl:template name="date">
    <!-- could probably use more robust handling -->
    <field name="date">
      <xsl:value-of select="$vra_date"/>
    </field>

    <field name="dateDisplay">
      <xsl:value-of select="/vra/work[1]/dateSet[1]/display[1]"/>
    </field>
  </xsl:template>


  <xsl:template name="title">
    <xsl:variable name="title">
      <xsl:value-of select="/vra/work[1]/titleSet[1]/title[1]"/>
    </xsl:variable>

    <field name="title">
      <xsl:value-of select="$title"/>
    </field>

    <field name="titleSort">
      <xsl:call-template name="normalize_name">
        <xsl:with-param name="string">
          <xsl:value-of select="$title"/>
        </xsl:with-param>
      </xsl:call-template>
    </field>
  </xsl:template>

  <!-- EXTRAS -->
  <xsl:template name="extras">

    <field name="dateSort_s">
      <xsl:value-of select="$vra_date"/>
    </field>

    <xsl:for-each select="/vra/work/subjectSet/subject">
      <!-- if term is not empty -->
      <xsl:if test="./term != ''">
      <field name="keywords">
        <xsl:value-of select="term"/>
      </field>
      </xsl:if>
    </xsl:for-each>

  </xsl:template>


</xsl:stylesheet>
