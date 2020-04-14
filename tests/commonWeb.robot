*** Settings ***
Resource          settings.robot

*** Keywords ***
### common ###
Get Repo Url
    [Arguments]    ${proj}=${PROJ}    ${repo}=${REPO}
    ${url}    Set Variable    ${BASE_URL}/projects/${PROJ}/repos/${repo}
    [Return]    ${url}

Get Project Url
    [Arguments]    ${proj}=${PROJ}
    ${url}    Set Variable    ${BASE_URL}/projects/${PROJ}
    [Return]    ${url}

Go To Url And Login
    [Arguments]    ${url}    ${username}    ${password}
    Open Browser    ${url}    ${BROWSER}
    Login    ${username}    ${password}

Login
    [Arguments]    ${username}    ${password}
    Input Text    css=input#j_username    ${username}
    Input Text    css=input#j_password    ${password}
    Click Element    css=input#submit