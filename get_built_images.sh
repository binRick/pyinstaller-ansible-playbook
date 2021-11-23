docker images|grep -v none|tr -s ' '|grep -v ^REPO|cut -d' ' -f1,2|sort -u
