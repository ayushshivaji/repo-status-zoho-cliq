#!/bin/bash

USER=ayush-sriva@github
PROJECT=sonar-test-ayush
SONAR_TOKEN=629a67cf6be30d0037d1f1c1d9bb40169c64600b
ZOHO_TOKEN=1000.eccbdecc709471c946088d1e38643319.a6bc43f6ab38eb735ff058508f333af2
RATING=$(curl -u $SONAR_TOKEN: "https://sonarcloud.io/api/measures/component?component=sonar-test-ayush&metricKeys=reliability_rating" | jq '.["component"]["measures"][0]["value"]')

cliq (){
    curl -H "Authorization:Zoho-oauthtoken $ZOHO_TOKEN" \
        -H "Content-Type:application/json" \
        "https://cliq.zoho.com/api/v2/channelsbyname/sonarnotifications/message" \
        -d {"text":"'$1'"}
}

# sonar-scanner

echo -e "Starting script at $(date)"
cliq "Starting script at $(date)"

if [[ $RATING == *"1"* ]]
then
    echo -e 'Repo Rating is A'
    cliq 'Repo Rating is A'
elif [[ $RATING == *"2"* ]]
then
    echo -e 'Repo Rating is B'
    cliq 'Repo Rating is B'
elif [[ "$RATING" == *"3"* ]]
then
    echo -e 'Repo Rating is C'
    cliq 'Repo Rating is C'
elif [[ $RATING == *"4"* ]]
then
    echo -e 'Repo Rating is D'
    cliq 'Repo Rating is D'
else
    echo -e 'Repo Rating is E'
    cliq 'Repo Rating is E'
fi

# Section for CRITICAL bugs

echo -e "Downloading BUGS with 'Critical' tag\n"

curl -u $SONAR_TOKEN: "https://sonarcloud.io/api/issues/search?componentKeys=$PROJECT&severities=CRITICAL&types=BUG" | jq '.["issues"][]["key"]' > bugs.json
sed -i 's/\"//g' bugs.json
BUGS=$(cat bugs.json)

if [[ $(cat bugs.json | wc -l) -ne 0 ]]
then
    
    echo -e "Iterating over the 'Critical' Issues\n"
    for LINE in $BUGS
    do
        echo $LINE
        curl -X POST \
            -u $SONAR_TOKEN: "https://sonarcloud.io/api/issues/assign?issue=$LINE&assignee=$USER"

        cliq "$LINE is assigned to $USER.\nCan be accessed here: https://sonarcloud.io/project/issues?severities=MAJOR&id=$PROJECT&open=$LINE"

        echo -e "\n"
    done
else
    echo 'No bugs found in CRITICAL section'
fi

# Section for MAJOR bugs

echo -e "Downloading BUGS with 'MAJOR' tag\n"

curl -u $SONAR_TOKEN: "https://sonarcloud.io/api/issues/search?componentKeys=$PROJECT&severities=MAJOR&types=BUG" | jq '.["issues"][]["key"]' > bugs.json
sed -i 's/\"//g' bugs.json
BUGS=$(cat bugs.json)

if [[ $(cat bugs.json | wc -l) -ne 0 ]]
then
    
    echo -e "Iterating over the 'MAJOR' Issues\n"
    for LINE in $BUGS
    do
        echo $LINE
        curl -X POST \
            -u $SONAR_TOKEN: "https://sonarcloud.io/api/issues/assign?issue=$LINE&assignee=$USER"

        cliq "$LINE is assigned to $USER.\nCan be accessed here: https://sonarcloud.io/project/issues?severities=MAJOR&id=$PROJECT&open=$LINE"

        echo -e "\n"
    done
else
    echo 'No bugs found in MAJOR section'
fi
