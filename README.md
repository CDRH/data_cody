# Data Repository for The William F. Cody Archive

## About This Data Repository

**How to Use This Repository:** This repository is intended for use with the [CDRH API](https://github.com/CDRH/api) and the [Cody Coccon application](https://github.com/CDRH/cocoon_cody).

**Data Repo:** [https://github.com/CDRH/data_cody](https://github.com/CDRH/data_cody)

**Source Files:** TEI XML

**Script Languages:** XSLT, JavaScript, Ruby

**Encoding Schema:** [Text Encoding Initiative (TEI) Guidelines](https://tei-c.org/release/doc/tei-p5-doc/en/html/index.html) & [VRA Core](https://www.loc.gov/standards/vracore/)

## About The William F. Cody Archive

 The William F. Cody Archive is a scholarly digital archive that offers an unequaled opportunity to see the historic evolution and idealization of the American West through the eyes of William F. “Buffalo Bill” Cody, presenting researchers and visitors an insightful perspective of America and the world spanning the late nineteenth and early twentieth centuries.

The William F. Cody Archive documents Cody's interactions with individuals ranging from statesmen and royalty to noted military and literary figures who sought his opinions on policy questions concerning the American West. His lesser-known roles as a community founder, businessman, rancher, and investor speak to political, economic, and environmental policies affecting western development during his lifetime. These experiences are represented by a variety of archival material: memoirs and autobiographies, correspondence, business records, published and unpublished writings, photographs, video and audio recordings, promotional and Wild West material, newspaper and magazine articles. The Archive aims to identify and make available as much of this material as possible, drawing on the resources of libraries and collections from around the United States and around the world. 

The William F. Cody Archive is directed by Jeremy M. Johnston (Buffalo Bill Center of the West), Frank Christianson (Brigham Young University), Douglas Seefeldt (Ball State University), and Katherine Walter (University of Nebraska).

**Project Site:** [https://codyarchive.org/](https://codyarchive.org/)

**Cocoon Repo:** [https://github.com/CDRH/cocoon_cody](https://github.com/CDRH/cocoon_cody)

**Credits:** [https://codyarchive.org/staff/](https://codyarchive.org/staff/)

**Work to Be Done:** [https://github.com/CDRH/cocoon_cody/issues](https://github.com/CDRH/cocoon_cody/issues)

## Editorial Policy

The corpus of materials associated with William F. Cody is large and scattered in uncounted collections both public and private throughout the United States and Europe. The Papers' editorial staff identifies new material on an ongoing basis. Consequently, the archive is highly dynamic; as significant new items come to our attention, we seek to publish them in their proper context. As new details come to light about relevant people and events, we refine the interpretive apparatus, from annotations to personographies, for greater accuracy. See the [Cody Archive About page](https://codyarchive.org/about/) for the full policy.

## Conditions of Use

You do not need to request permission to link to The William F. Cody Archive or to individual items within the site. (Please note that URLs may change over time.)

To identify The William F. Cody Archive as the source of information that you are using in a paper, article, book, blog post, slide show, or other print or electronic communication medium, please include the complete title of the item, the name of the site, its URL, and the date you accessed it. Here are examples in a variety of citation styles:

APA: The William F. Cody Archive. “Letter from William F. Cody to Julia Cody Goodman, April 22, 1876.” The Papers of William F. Cody. Retrieved February 26, 2011 from http://codyarchive.org/texts/wfc.css00038.html

Chicago/Turabian: The William F. Cody Archive. “Letter from William F. Cody to Julia Cody Goodman, April 22, 1876.” The Papers of William F. Cody. http://codyarchive.org/texts/wfc.css00038.html (retrieved February 26, 2011).

MLA: The William F. Cody Archive. “Letter from William F. Cody to Julia Cody Goodman, April 22, 1876.” The Papers of William F. Cody. 26 February 2011. <http://codyarchive.org/texts/wfc.css00038.html>

The William F. Cody Archive, Buffalo Bill Center of the West and University of Nebraska-Lincoln. Published under a [Creative Commons License](https://creativecommons.org/licenses/by-nc-sa/3.0/).

## Technical Information

See the [Datura documentation](https://github.com/CDRH/datura) for general updating and posting instructions. 

### Updating the Site

There are two separate aspects of the update process:  the HTML being displayed by cocoon and the Solr powered search results.  The former is updated simply by pulling updates to the data repository on the dev or production server.  The latter requires you to run a posting script.  Both require you to "break" the cocoon site to see the changes.

The following instructions assume you are working directly on the master branch, but if this is not the case, please consult a CDRH developer for the best workflow to review branches and merge changes.

Commit and push your local changes.

Log into the dev server (cdrhdev1) or the production server depending on where you are deploying these changes, navigate to the data repository location, and pull your recent code.  It's recommended that you try this out on the dev server before deploying to production.

```bash
www
cd data/collections/cody_archive

# confirm that the server is on the master branch and that there are not
# any changes which need to be dealt with before pulling
git status

git pull
```

Now you may post the files to solr.  You may specify a particular file by using the `-r` flag and part or all of the filename before the extension (`-r wfc.00001`)

```bash
bundle exec post -x solr
```

If you RENAMED or REMOVED any files, you will also need to remove them from the index (substitute `wfc.00001` with the correct id):

```bash
bundle exec solr_clear_index -r wfc.00001
```

Now you will need to break the cocoon map.

```bash
mv ../../../cocoon/codyarchive.org/stylesheets/xslt/tei.p5.xsl ../../../cocoon/codyarchive.org/stylesheets/xslt/tei.p5.tmp.xsl
```

Refresh the cody archive website on either the dev site or the production site, depending on where you are running these commands, confirm that it is broken, then run:

```bash
mv ../../../cocoon/codyarchive.org/stylesheets/xslt/tei.p5.tmp.xsl ../../../cocoon/codyarchive.org/stylesheets/xslt/tei.p5.xsl
```

You will also need to repeat the above steps on the facets file (`stylesheets/xslt/solr2json-facets.xsl`) to update the search facets.  

### VRA Files

VRA Files must have one of the following in their filenames in order to be populated into one of the 6 visual materials categories: 

1. .pho OR .pht = photographs
2. .pc = postcards
3. .pst = posters
4. .ill = illustrations
5. .va = visual_art
6. .cc = cabinet_cards

(This corresponds to this code: https://github.com/CDRH/data_cody/blob/master/scripts/overrides/vra_to_solr.xsl#L140 a future update could refine this)

## About the Center for Digital Research in the Humanities

The Center for Digital Research in the Humanities (CDRH) is a joint initiative of the University of Nebraska-Lincoln Libraries and the College of Arts & Sciences. The Center for Digital Research in the Humanities is a community of researchers collaborating to build digital content and systems in order to generate and express knowledge of the humanities. We mentor emerging voices and advance digital futures for all.

**Center for Digital Research in the Humanities GitHub:** [https://github.com/CDRH](https://github.com/CDRH)

**Center for Digital Research in the Humanities Website:** [https://cdrh.unl.edu/](https://cdrh.unl.edu/)
