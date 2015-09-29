#!/usr/bin/env bash
# See .gitlab-ci.yml for usage
set -x
[ "$CI_BUILD_REF" = "" ] && CI_BUILD_REF=$(( ( RANDOM % 100000 )  + 1 ))
[ "$CI_BUILD_REF_NAME" = "" ] && CI_BUILD_REF_NAME=$(git symbolic-ref --short -q HEAD)
[ "$CI_BUILD_REF_NAME" = "master" ] && CI_BUILD_REF_NAME="latest"
POSTGRES_PASSWORD="zup"
POSTGRES_USER="zup"
SHARED_BUFFERS=128MB
POSTGRES_NAME="postgres$CI_BUILD_REF_NAME$CI_BUILD_REF"
REDIS_NAME="redis$CI_BUILD_REF_NAME$CI_BUILD_REF"
RUBOCOP_NAME="rubocop$CI_BUILD_REF_NAME$CI_BUILD_REF"
API_BRANCH=$CI_BUILD_REF_NAME
NODE_INDEX=$2
CI_NODE_TOTAL=$3

cleanup() {
    kill -9 $BUILD_PID || true
    docker rm -f $(docker ps -q -a --filter "label=build=$CI_BUILD_REF")
}

error_handler() {
    exit_code=$?
    echo "Error on line $1"
    cleanup
    exit $exit_code
}

trap 'error_handler $LINENO' ERR

build() {
    docker run --label build=$CI_BUILD_REF -d --name $POSTGRES_NAME -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -e POSTGRES_USER=$POSTGRES_USER -e POSTGRES_DB=$ZUP_DB -e SHARED_BUFFERS=64MB ntxcode/postgresql:9.4
    docker build -t ntxcode/zup-api:$CI_BUILD_REF_NAME . &
    BUILD_PID=$!
    wait $BUILD_PID
    docker run --label build=$CI_BUILD_REF --rm --link $POSTGRES_NAME:postgres -e RACK_ENV=test -e DATABASE_URL=postgis://zup:zup@postgres/default ntxcode/zup-api:$CI_BUILD_REF_NAME bundle exec rake db:create db:schema:load
}

rubocop() {
    DATABASE_URL="postgis://zup:zup@postgres/default"
    docker run --label build=$CI_BUILD_REF --rm -a stdout -a stderr -e DATABASE_URL=$DATABASE_URL --name $RUBOCOP_NAME ntxcode/zup-api:$CI_BUILD_REF_NAME bundle exec rubocop
}

test_node() {
      ZUP_DB="zup$NODE_INDEX"
      docker exec $POSTGRES_NAME /bin/bash -c "PG_PASSWORD=$POSTGRES_PASSWORD createdb --user $POSTGRES_USER -O $POSTGRES_USER -T default $ZUP_DB"
      docker run --label build=$CI_BUILD_REF --rm --link $POSTGRES_NAME:postgres -e RACK_ENV=test -e DATABASE_URL=postgis://zup:zup@postgres/$ZUP_DB -e CI_NODE_TOTAL=$CI_NODE_TOTAL -e CI_NODE_INDEX=$NODE_INDEX ntxcode/zup-api:$CI_BUILD_REF_NAME bundle exec rake knapsack:rspec
}

deploy() {
    docker login -e $DOCKER_LOGIN -p $DOCKER_PASSWORD -u $DOCKER_USERNAME
    docker push ntxcode/zup-api:$CI_BUILD_REF_NAME
    curl -X POST -H "Content-Type: application/json" -d "{ \\"project_name\\": \\"zup\\", \\"branch\\": \\"${CI_BUILD_REF_NAME}\\" }" http://dubious-tortoise.staging.ntxdev.com.br:9292/default/hook
    cleanup
}

case "$1" in
    build) build; exit 0
        ;;
    rubocop) rubocop
        ;;
    test) test_node
        ;;
    deploy) deploy
        ;;
    *)
        build
        rubocop &
        CI_NODE_TOTAL=4
        NODE_INDEX=0
        test_node &
        NODE_INDEX=1
        test_node &
        NODE_INDEX=2
        test_node &
        NODE_INDEX=3
        test_node &
        for job in `jobs -p`
        do
            wait $job
        done
        cleanup
        ;;
esac
