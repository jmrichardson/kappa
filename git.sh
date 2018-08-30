# Simple script to update github and merge with any master updates

# Change directory
cd ~/kappa
[ $? -ne 0 ] && echo "Error: no ~/kappa directory"

# Add all to local repo
git add -A
[ $? -ne 0 ] && echo "Error: Unable to add to index"

# Commit to repo with message
git commit -m "New commit"
[ $? -ne 0 ] && echo "Error: Unable to commit changes to local repo"

# Download any master commits (other people edits)
git fetch origin
[ $? -ne 0 ] && echo "Error: Unable to download changes from master repo"

# Merge without commit message
git merge origin/master master --no-edit
[ $? -ne 0 ] && echo "Error: Unable to merge local and master commits"

# Push to master
git push origin master
[ $? -ne 0 ] && echo "Error: Unable to update master branch"
