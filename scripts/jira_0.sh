#!/bin/bash

currentTime=`date +%k%M`
send_message()
{
    tempTime=$1
          
    MESSAGE="Please update and log time to the Jira issues assigned to you \n https://mocglobal.atlassian.net/secure/RapidBoard.jspa?rapidView=167&projectKey=PM&selectedIssue=PM-153"
    echo $MESSAGE

    curl -X POST \
         -H 'Content-Type: application/json' \
         -d '{ "recipient": { "thread_key": "2553112934760190" }, "message": { "text": "'"$MESSAGE"'" } }' \
         https://graph.facebook.com/v2.10/me/messages?access_token="DQVJ1YVlWWlNjamVUdFNLVkZAVNXBxZAFRpQnduN04zUnJvOWgxNUtYRm96RV94NWxsTGlvY3lVR1VSRU9acWRvWnJkbEZAwc0FHdm1vRThLTUtIZA1RZAT0tTM0ZAqRkNzZA2tCRDlRZAWNBVnFPRzNMbUIzMlBJTWpfN0ExWWFrWXJLQUdzWTZA6cFRaeWo4dU1ldF9OZATJ1b3hBd2VHeTZApRFQweXdnVDhVNC14S0xneUdKRWc5V3gtQUtpLVNXT25VRW13R005YjN3"

}

send_message $currentTime
