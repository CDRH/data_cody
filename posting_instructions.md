## Posting Instructions (Cody Archive)

There are two aspects of the update process: the HTML generation and the population of the search results in Elasticsearch. Both updates require you to run a posting script. 

The following instructions assume you are working directly on the master branch, but if this is not the case, please consult a CDRH developer for the best workflow to review branches and merge changes.

### Log into server

Make sure you are on the VPN if not on campus. Log into the dev server (cdrhdev1) or the production server depending on where you are deploying these changes, navigate to the data repository location, and pull your recent code. It's recommended that you try this out on the dev server before deploying to production.

In terminal: 

```bash
ssh <username>@cdrhrailsdev.unl.edu
```

### Navigate to directory

Typing `www` will get you to the web root and you can navigate from there, or type this to go straight to the cody data repo: 

```bash
cd /var/local/www/collections/cody_archive
```

### Pull most recent files

(If you have not set up a ssh key yet, you'll need to see the [instructions at the bottom of this document](#set-up-ssh-key)).

```bash
# confirm that the server is on the master branch and that there are not
# any changes which need to be dealt with before pulling
git status

git pull
```

### Post Files

From here on out, you should be able to update and post files as outlined in the [datura documentation](https://github.com/CDRH/datura/blob/dev/docs/3_manage/post.md).

Note that any errors will be in line, so you might have to scroll up to see if there were, for instance, errors with your HTML transformations. 

### Set up ssh key 

(you only have to do this once)

There are instructions on the [github website](https://docs.github.com/en/enterprise/2.13/user/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key), but **be sure to click on "linux" in the tab bar right under the title**  

#### then, add it to github

Follow [these instructions form github](https://docs.github.com/en/enterprise/2.13/user/articles/adding-a-new-ssh-key-to-your-github-account) to add to your account

When you get to the instruction that asks you to use "xclip" run this command instead: 

`cat ~/.ssh/id_rsa.pub`

and then copy the key from there

## Legacy Posting and Update Instructions

The following instructions apply to the old Cocoon site and have been kept here for reference. 

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
