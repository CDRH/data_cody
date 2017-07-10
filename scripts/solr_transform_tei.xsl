<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="#all">
  
  <!-- ==================================================================== -->
  <!--                               IMPORTS                                -->
  <!-- ==================================================================== -->

  <xsl:import href="../../../scripts/xslt/cdrh_to_solr/lib/common.xsl"/>
  <xsl:import href="../../../scripts/xslt/cdrh_to_solr/lib/tei_personography.xsl"/>
  <xsl:import href="../../../scripts/xslt/cdrh_to_solr/lib/cdrh_tei.xsl"/>
  <!-- If this file is living in a projects directory, the paths will be
       ../../../scripts/xslt/cdrh_to_solr/lib/common.xsl -->

  <xsl:output indent="yes" omit-xml-declaration="yes"/>

  <!-- ==================================================================== -->
  <!--                           PARAMETERS                                 -->
  <!-- ==================================================================== -->

  <!-- Defined in project config files -->
  <xsl:param name="fig_location"/>  <!-- url for figures -->
  <xsl:param name="file_location"/> <!-- url for tei files -->
  <xsl:param name="figures"/>       <!-- boolean for if figs should be displayed (not for this script, for html script) -->
  <xsl:param name="fw"/>            <!-- boolean for html not for this script -->
  <xsl:param name="pb"/>            <!-- boolean for page breaks in html, not this script -->
  <xsl:param name="project"/>       <!-- longer name of project -->
  <xsl:param name="slug"/>          <!-- slug of project -->
  <xsl:param name="site_url"/>
        

  <!-- ==================================================================== -->
  <!--                            OVERRIDES                                 -->
  <!-- ==================================================================== -->

  <!-- Individual projects can override matched templates from the
       imported stylesheets above by including new templates here -->
  <!-- Named templates can be overridden if included in matched templates
       here.  You cannot call a named template from directly within the stylesheet tag
       but you can redefine one here to be called by an imported template -->

      <!-- The below will override the entire text matching template -->
      <!-- <xsl:template match="text">
        <xsl:call-template name="fake_template"/>
      </xsl:template> -->

      <!-- The below will override templates with the same name -->
      <!-- <xsl:template name="fake_template">
        This fake template would override fake_template if it was defined
        in one of the imported files
      </xsl:template> -->


  <!-- Uncomment these to prevent personography behavior -->
  <!-- <xsl:template name="personography"/> -->
  
  <xsl:template name="extras">
    <field name="dateSort_s">
      <xsl:choose>
        <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when or /TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notBefore">
          <xsl:choose>
            <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notBefore">
              <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notBefore"/>
              <xsl:text> circa</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when"/>
              <xsl:text> zzz</xsl:text> <!-- To sort after circas -->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>undated</xsl:otherwise> <!-- When no @when or @notBefore exist -->
      </xsl:choose>
    </field>
    
    <field name="itemCategory_s">
      <xsl:text>texts</xsl:text>
    </field>
  </xsl:template>

  <xsl:template name="rightsURI">
    <field name="rightsURI">http://centerofthewest.org/research/rights-reproductions/</field>
  </xsl:template>

  <xsl:template name="image_id">
    <field name="image_id">
      <xsl:choose>
        <xsl:when test="//pb">
          <xsl:for-each select="//pb">
            <xsl:if test="position() = 1">
              <xsl:value-of select="@facs"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>icon-</xsl:text>
          <xsl:value-of select="lower-case(/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory']/term)"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
 
  <xsl:template name="date">
    <xsl:variable name="doc_date">
      <xsl:choose>
        <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when">
            <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when"/>
        </xsl:when>
        <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notBefore">
            <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notBefore"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
      
      <field name="date">
        <xsl:call-template name="date_standardize">
          <xsl:with-param name="datebefore">
            <xsl:value-of select="substring($doc_date,1,10)"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>T00:00:00Z</xsl:text>
      </field>
    
      <!-- dateDisplay -->
      <field name="dateDisplay">
        <xsl:variable name="display_date">
          <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/bibl/date[1])"/>
        </xsl:variable>
        <xsl:value-of select="$display_date"/>
      </field>
    
  </xsl:template>

</xsl:stylesheet>
