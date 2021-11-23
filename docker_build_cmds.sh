ls Dockerfile* | xargs -I % echo docker build -f % .
