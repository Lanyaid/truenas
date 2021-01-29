#/usr/bin/bash
set -x
git add .
git status
if (( $( git status | grep "modified" | wc -l ) >= 1 | $( git status | grep "new file" | wc -l ) >= 1 | $( git status | grep "deleted" | wc -l ) >= 1 ))
then
  git add .
  git commit -a
  git -c http.sslVerify=false push
else
  echo -e "\nGit repo up to date. Nothing to commit.\nNothing to push."
fi

