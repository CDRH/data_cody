<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="dc rdf" >
	<xsl:output indent="yes"/>

	<xsl:param name="type"><xsl:value-of select="local-name(/)"/>ccc</xsl:param>

	<xsl:template match="*[not(parent::*)]">


<!-- Setting the type of the document, either RDF for images or TEI for texts -->
		<xsl:variable name="type">
			<xsl:value-of select="local-name()"/>
		</xsl:variable>

		
<!-- Differing indexes depending on whether document is RDF/image or TEI/text -->
		<xsl:choose>
			<!-- Images are RDF -->
			
	<!-- ============================================================================
	IMAGE INDEXING
	==============================================================================-->
			
			<xsl:when test="$type = 'RDF'">
				<add>
					<xsl:for-each select="rdf:Description">
						<doc>
							<field name="id">
								<xsl:value-of select="dc:identifier"/>
							</field>

							<field name="category">
								<xsl:text>Images</xsl:text>
							</field>

							<!-- Setting the type of image by the file it is found in - wfc.photographs.xml, wfc.postcards.xml, etc.
							Could be simplified...-->
							<xsl:variable name="filename" select="tokenize(document-uri(/), '/')[last()]" />
							<field name="subCategory">
								
								<xsl:choose>
									<xsl:when test="contains($filename, 'photographs')">
										<xsl:text>photographs</xsl:text>
									</xsl:when>
									<xsl:when test="contains($filename, 'postcards')">
										<xsl:text>postcards</xsl:text>
									</xsl:when>
									<xsl:when test="contains($filename, 'posters')">
										<xsl:text>posters</xsl:text>
									</xsl:when>
									<xsl:when test="contains($filename, 'illustrations')">
										<xsl:text>illustrations</xsl:text>
									</xsl:when>
									<xsl:when test="contains($filename, 'visual_art')">
										<xsl:text>visual art</xsl:text>
									</xsl:when>
									<xsl:when test="contains($filename, 'cabinet_cards')">
										<xsl:text>cabinet cards</xsl:text>
									</xsl:when>
								</xsl:choose>
							</field>

							<field name="titleMain">
								<xsl:value-of select="dc:title"/>
							</field>

							<field name="author">
								<xsl:value-of select="dc:creator"/>
							</field>
							
							<!-- Call the template that will set the dates -->
							<xsl:call-template name="setDates">
								<xsl:with-param name="type" select="$type"/>
							</xsl:call-template>
							
							<field name="dateSort">
								<xsl:choose>
									<xsl:when test="dc:date[1] = ''">undated</xsl:when>
									<!--<xsl:when test="contains(dc:date[1],'-')">
										<xsl:value-of select="substring(dc:date,7,4)"/>
									</xsl:when>-->
									<xsl:when test="contains(dc:date[1],'circa')">
										<xsl:value-of select="substring(dc:date,7,4)"/>
										<xsl:text> circa</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="dc:date"/>
										<xsl:text> zzz</xsl:text> <!-- To sort after circas -->
									</xsl:otherwise>
								</xsl:choose>
							</field>

							<xsl:for-each select="dc:subject">
								<xsl:if test=". != ''">
									<xsl:choose>
										<xsl:when test=". = 'European Tours' or
														. = 'Show Indians' or
														. = 'Empire' or
														. = 'Rough Riders'">
											<field name="topic">
												<xsl:value-of select="normalize-space(.)"/>
											</field>
											<field name="keywords">
												<xsl:value-of select="normalize-space(.)"/>
											</field>
										</xsl:when>
										<xsl:otherwise>
											<field name="keywords">
												<xsl:apply-templates/>
											</field>
										</xsl:otherwise>
									</xsl:choose>
									
								</xsl:if>
							</xsl:for-each>

							<!-- Temporary, will fill in correctly later
							People and places search is not surrently enabled for images because we 
							need to find a way to express in Dublin Core-->
							<!--<field name="people"> </field>-->

							<!-- Temporary, will fill in correctly later  -->
							<!--<field name="places"> </field>-->
							
							<!-- Temporary, will fill in correctly later  -->
							<!--<field name="topic"> </field>-->

							<field name="imageID">
								<xsl:value-of select="dc:identifier"/>
							</field>

							<xsl:if test="dc:description != ''">
								<field name="text">
								<xsl:value-of select="dc:description"/>

							</field>
							</xsl:if>
			
						</doc>
					</xsl:for-each>
				</add>
			</xsl:when>

			<!-- All documents but images -->
			
	<!-- ============================================================================
	PERSONOGRAPHY INDEXING
	==============================================================================-->
			
			<xsl:when test="$type = 'TEI'">
				<xsl:choose>
					<xsl:when test="/TEI/@xml:id = 'wfc.person'">
						<add><xsl:for-each select="//person">
							
								<doc>
									<field name="id">
										<xsl:value-of select="@xml:id"/>
									</field>
									
									<field name="category">
										<xsl:value-of
											select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='category']/term"/>
									</field>
									
									<field name="subCategory">
										<xsl:value-of
											select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory']/term"/>
									</field>
									
									<field name="itemCategory">
										<xsl:text>texts</xsl:text>
									</field>
									
									<field name="searchBoost">
										<xsl:value-of select="persName[@type='full']"/>
									</field>
									
									<field name="titleMain">
										<xsl:value-of select="persName[@type='display']"/>
									</field>
									
									<xsl:choose>
										<xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/author[1] and /TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/author[1] !=''">
											<xsl:for-each select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/author">
												<field name="author">
													<xsl:apply-templates/>
												</field>
											</xsl:for-each>
										</xsl:when>
										<xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/author[1] and /TEI/teiHeader/fileDesc/titleStmt/author[1] != ''">
											<xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/author">
												<field name="author">
													<xsl:apply-templates/>
												</field>
											</xsl:for-each>
										</xsl:when>
									</xsl:choose>
									
									<xsl:call-template name="setDates">
										<xsl:with-param name="type" select="$type" />
									</xsl:call-template>
									
									<field name="dateSort">
										<xsl:text>0</xsl:text>
									</field>
									
									
									<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term">
										<xsl:if test=". != ''">
											<field name="topic">
												<xsl:apply-templates/>
											</field>
										</xsl:if>
									</xsl:for-each>
									
									<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term">
										<xsl:if test=". != ''">
											<field name="keywords">
												<xsl:apply-templates/>
											</field>
										</xsl:if>
									</xsl:for-each>
									
									<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term">
										<xsl:if test=". != ''">
											<field name="people">
												<xsl:apply-templates/>
											</field>
										</xsl:if>
									</xsl:for-each>
									
									<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term">
										<xsl:if test=". != ''">
											<field name="places">
												<xsl:apply-templates/>
											</field>
										</xsl:if>
									</xsl:for-each>
									
									<!-- For the imageID, find the first image (//pb right now) in a document, or use the
						default icon if no images-->
									
									<field name="imageID">
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
												<xsl:value-of
													select="lower-case(/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory']/term)"
												/>
											</xsl:otherwise>
										</xsl:choose>
									</field>
									
									
									<!--<field name="text">
							<xsl:value-of select="note" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="text" />
						</field>-->
								</doc>
							 
						</xsl:for-each></add>
					</xsl:when>
					
	<!-- ============================================================================
	TEXT INDEXING
	==============================================================================-->
					<xsl:otherwise>
						<add>
							<doc>
								<field name="id">
									<xsl:value-of select="/TEI/@xml:id"/>
								</field>
								
								<field name="category">
									<xsl:value-of
										select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='category']/term"/>
								</field>
								
								<field name="subCategory">
									<xsl:value-of
										select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory']/term"/>
								</field>
								
								<field name="itemCategory">
									<xsl:text>texts</xsl:text>
								</field>
								
								<field name="titleMain">
									<xsl:choose>
										<xsl:when
											test="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']">
											<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[@type='main']"/>
										</xsl:when>
										<xsl:when
											test="/TEI/teiHeader/fileDesc/titleStmt/head[@type='main']">
											<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/head[@type='main']"/>
										</xsl:when>
										<xsl:otherwise> notitle </xsl:otherwise>
									</xsl:choose>
								</field>
								
								<xsl:choose>
									<xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/author[1] and /TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/author[1] !=''">
										<xsl:for-each select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/author">
											<field name="author">
												<xsl:apply-templates/>
											</field>
										</xsl:for-each>
									</xsl:when>
									<xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/author[1] and /TEI/teiHeader/fileDesc/titleStmt/author[1] != ''">
										<xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/author">
											<field name="author">
												<xsl:apply-templates/>
											</field>
										</xsl:for-each>
									</xsl:when>
								</xsl:choose>
								
								<xsl:call-template name="setDates">
									<xsl:with-param name="type" select="$type" />
								</xsl:call-template>
								
								<field name="dateSort">
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
								
								
								<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term">
									<xsl:if test=". != ''">
										<field name="topic">
											<xsl:apply-templates/>
										</field>
									</xsl:if>
								</xsl:for-each>
								
								<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term">
									<xsl:if test=". != ''">
										<field name="keywords">
											<xsl:apply-templates/>
										</field>
									</xsl:if>
								</xsl:for-each>
								
								<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term">
									<xsl:if test=". != ''">
										<field name="people">
											<xsl:apply-templates/>
										</field>
									</xsl:if>
								</xsl:for-each>
								
								<xsl:for-each select="/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term">
									<xsl:if test=". != ''">
										<field name="places">
											<xsl:apply-templates/>
										</field>
									</xsl:if>
								</xsl:for-each>
								
								<!-- For the imageID, find the first image (//pb right now) in a document, or use the
						default icon if no images-->
								
								<field name="imageID">
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
											<xsl:value-of
												select="lower-case(/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory']/term)"
											/>
										</xsl:otherwise>
									</xsl:choose>
								</field>
								
								
								<field name="text">
							<xsl:value-of select="note[@type='project']" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="text" />
						</field>
							</doc>
						</add>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	DATE TEMPLATES
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:template name="setDates">
		<xsl:param name="type"/>
		
		<xsl:variable name="rdfType" select="'RDF'"/>
		<xsl:variable name="teiType" select="'TEI'"/>

		<!-- Set the date from the document -->
		<!-- Todo - cleanup this and below, normalize/prettyfy document dates when needed -->
		<field name="date">
			<xsl:choose>
				<xsl:when test="$type=$rdfType">
					<xsl:choose>
						<xsl:when test="dc:date and dc:date != ''">
							<xsl:value-of select="dc:date"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>undated</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$type=$teiType">
					<xsl:choose>
						<xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date and /TEI/teiHeader/fileDesc/sourceDesc/bibl/date != ''">
							<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>undated</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</field>

		<!-- Set a variable "date" from the document's normalized view -->
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="$type = $rdfType">
					<xsl:value-of select="dc:date"/>
				</xsl:when>
				<xsl:when test="$type = $teiType">
					<xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="yearMonthDayRegex">^(circa )?[0-9]{4}(s)?(-[0-9]{2}(-[0-9]{2})?)?$</xsl:variable>
		<xsl:variable name="yearRangeRegex">^(circa )?[0-9]{4}-[0-9]{4}$</xsl:variable>
		<xsl:variable name="blankRegex">^$</xsl:variable>

		<xsl:choose>
			
			<xsl:when test="matches($date,$yearMonthDayRegex)">
				<xsl:call-template name="setDateSearchAndYear">
					<xsl:with-param name="initDate" select="$date" />
				</xsl:call-template>
			</xsl:when>
			
			<xsl:when test="matches($date,$yearRangeRegex)">
				
				<xsl:variable name="startYear">
					<xsl:choose>
						<xsl:when test="contains($date,'circa ')">
							<xsl:value-of select="substring($date,7,4)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring($date,1,4)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="endYear">
					<xsl:choose>
						<xsl:when test="contains($date,'circa ')">
							<xsl:value-of select="number(substring($date,12,4))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="number(substring($date,6,4))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="recursivelySetDates">
					<xsl:with-param name="currentYear" select="$startYear"/>
					<xsl:with-param name="maxYear" select="$endYear"/>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:when test="matches($date,$blankRegex)">
				<!-- Label as ubdated when date is blank -->
				<field name="dateSearch">undated</field>
				<field name="year"/>
			</xsl:when>
			<!--
				<xsl:otherwise>
		        </xsl:otherwise>
			-->
		</xsl:choose>
	</xsl:template>

	<xsl:template name="recursivelySetDates">
		<xsl:param name="maxYear"/>
		<xsl:param name="currentYear"/>

		<xsl:choose>
			<xsl:when test="$currentYear &lt;= $maxYear">
				<xsl:call-template name="setDateSearchAndYear">
					<xsl:with-param name="initDate" select="$currentYear" />
				</xsl:call-template>
				
				<xsl:call-template name="recursivelySetDates">
					<xsl:with-param name="currentYear" select="$currentYear + 1"/>
					<xsl:with-param name="maxYear" select="$maxYear"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="setDateSearchAndYear">
		<xsl:param name="initDate" />
		
		<xsl:variable name="finalDate">
			<xsl:choose>
				<xsl:when test="contains(string($initDate),'circa ')">
					<xsl:value-of select="number(substring(string($initDate),7,4))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$initDate" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<field name="dateSearch">
			<xsl:value-of select="$finalDate"/>
		</field>
		
		<field name="year">
			<xsl:value-of select="substring($finalDate,1,4)"/>
		</field>
		
	</xsl:template>
	
</xsl:stylesheet>
