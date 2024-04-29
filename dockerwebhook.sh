#!/bin/bash

PORT=7777
data_file=/tmp/payload_data.json
workspace=prajwal

#function to continously read the webhook data and store in file 
read_payload(){
    json_data=$(nc -l $PORT)
    echo "$json_data" > $data_file
}

#function to extract the tag name and repo name form the docker hub webhook
extract_tag_and_reponame() {
    tag=$(grep -o '"tag":"[^"]*"' "$data_file" | awk -F'"' '{print $4}')
    repo_name=$(grep -o '"repo_name":"[^"]*"' "$data_file" | awk -F'"' '{print $4}')
}

#main function
main(){
    read_payload
    extract_tag_and_reponame
    if [ $tag == "latest" ]; then
        kubectl rollout restart deploy webhook-deployment -n $workspace
        echo "deployment restarted with latest tag"
    else
        kubectl set image deployment/webhook-deployment webhook-app=$repo_name:$tag -n $workspace
        echo "deployment restarted with new tag "
    fi
}

#infinite loop
while true; 
do
    main
done


