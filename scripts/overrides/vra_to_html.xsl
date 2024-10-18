<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.vraweb.org/vracore4.htm"
    version="2.0"
    exclude-result-prefixes="xsl tei xs">
    
    <!-- ==================================================================== -->
    <!--                             IMPORTS                                  -->
    <!-- ==================================================================== -->
    <xsl:import href="../.xslt-datura/tei_to_html/tei_to_html.xsl"/>
    <xsl:import href="../.xslt-datura/vra_to_html/vra_to_html.xsl"/>
    
    <!-- <xsl:import href="some_vra_file.xsl"/> -->
    
    <!-- To override, copy this file into your collection's script directory
      and change the above paths to:
      "../../.xslt-datura/vra_to_html/etc.xsl"
  -->
    
    <!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>
    
    
    <!-- ==================================================================== -->
    <!--                           PARAMETERS                                 -->
    <!-- ==================================================================== -->
    
    <xsl:param name="collection"/>
    <xsl:param name="site_url"/>                <!-- the site url (http://codyarchive.org) -->
    <xsl:param name="fig_location"></xsl:param> <!-- set figure location  -->
    
    <xsl:template match="/">
        <html>
            <xsl:for-each select="/vra/work[1]">
                <div class="images_file">
                    <img>
                        <xsl:attribute name="src">
                            <xsl:variable name="figure_id" select="./@id"/>
                            <xsl:call-template name="url_builder">
                                <xsl:with-param name="figure_id_local" select="$figure_id"/>
                                <xsl:with-param name="image_size_local" select="$image_large"/>
                                <xsl:with-param name="iiif_path_local" select="$collection"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </div> <!-- /images_file -->
            </xsl:for-each>
            <div class="image_description"><xsl:value-of select="//description"/></div>
        </html>
    </xsl:template>
    
    <!-- ==================================================================== -->
    <!--                            OVERRIDES                                 -->
    <!-- ==================================================================== -->
    
    <!-- Individual collections can override matched templates from the
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
    

    
</xsl:stylesheet>