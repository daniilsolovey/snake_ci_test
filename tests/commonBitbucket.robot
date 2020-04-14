*** Settings ***
Resource          settings.robot

*** Keywords ***
Create Pull Request
    [Arguments]    ${uri}    ${project}    ${repo}    ${source}
    ${result}    Run Process Wrapper    stacket    --uri    ${uri}    pull-requests    create    ${project}    ${repo}    ${source}    cwd=${repo_dir}
    ${pull_url}    Get Lines Containing String    ${result.stdout}    http
    [Return]    ${pull_url}

Create Project
    [Arguments]    ${uri}    ${project}
    ${result}    Run Process Wrapper    stacket    --uri    ${uri}    projects    create    ${project}
    Should Be Equal As Integers	   ${result.rc}	   0

Create Repository
    [Arguments]    ${uri}    ${project}    ${repo}
    #${repo}    Generate Random String    8    [LOWER]
    ${result}    Run Process Wrapper    stacket    --uri    ${uri}    repositories    create    ${project}    ${repo}
    Should Be Equal As Integers	   ${result.rc}	   0
    ${http_url}    Get Lines Containing String    ${result.stdout}    http:
    ${ssh_url}    Get Lines Containing String    ${result.stdout}    ssh:
    [Return]    ${http_url}    ${ssh_url}

Delete Project

Delete Repository
