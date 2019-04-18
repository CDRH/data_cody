# Cody Archive Data Repository

This repository contains TEI and VRA documents from which website content and search results are created for http://codyarchive.org/.

## Updating the Site

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

## VRA Files

VRA Files must have one of the following in their filenames in order to be populated into one of the 6 visual materials categories: 

1. .pho OR .pht = photographs
2. .pc = postcards
3. .pst = posters
4. .ill = illustrations
5. .va = visual_art
6. .cc = cabinet_cards

(This corresponds to this code: https://github.com/CDRH/data_cody/blob/master/scripts/overrides/vra_to_solr.xsl#L140 a future update could refine this)
