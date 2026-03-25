#!/bin/bash
declare -a appEnv=("todo" "todo-dev" "todo-prod")
#todo2-backend.todo.svc.cluster.local:8080
for appEnv in "${appEnv[@]}"; do
    echo "=== $appEnv ===="
    count=0
    while [ $count -lt 10 ]; do
        let "count=count+1"
        curl -s -X POST "http://${appEnv}2-backend.${appEnv}.svc.cluster.local:8080/todos" \
            -H 'accept: application/json' -H 'Content-Type: application/json' \
            -d "{\"text\":\"It ${count} todo\" }"
        done
    curl "http://${appEnv}-backend.${appEnv}.svc.cluster.local:8080/metrics"
done
exit 0

# #!/bin/bash
# declare -a appEnv=("todo")
# #todo2-backend.todo.svc.cluster.local:8080
# for appEnv in "${appEnv[@]}"; do
#     echo "=== $appEnv ===="
#     count=0
#     while [ $count -lt 10 ]; do
#         let "count=count+1"
#         curl -s -X POST "http://${appEnv}2-backend.${appEnv}.svc.cluster.local:8080/todos" \
#             -H 'accept: application/json' -H 'Content-Type: application/json' \
#             -d "{\"text\":\"It ${count} todo\" }"
#         done
#     curl "http://${appEnv}-backend.${appEnv}.svc.cluster.local:8080/metrics"
# done
# exit 0
