#/usr/bin/bash
set -x
git add .
git status
GIT_MODIFIED=`git status | grep "modified" | wc -l | sed s/\ //g`
GIT_NEW_FILES=`git status | grep "new file" | wc -l | sed s/\ //g`
GIT_DELETED=`git status | grep "deleted" | wc -l | sed s/\ //g`

if [ "${GIT_MODIFIED}" -ge 1 ] || [ "${GIT_NEW_FILES}" -ge 1 ] || [ "${GIT_DELETED}" -ge 1 ]
then
  git add .
  git commit -a
  git -c http.sslVerify=false push
else
  echo -e "\nGit repo up to date. Nothing to commit.\nNothing to push."
fi

