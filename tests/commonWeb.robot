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

Get Pull request ID From Url
    [Arguments]    ${url}
    @{list}    Split String    ${url}    /
    [Return]    @{list}[-2]

Element Attribute Contains
    [Arguments]    ${element}    ${attribute}    ${value}
    ${value_full}    Get Element Attribute    ${element}    ${attribute}
    Should Contain    ${value_full}    ${value}

## Runner variables
Add A Var In Setting
    [Arguments]    ${name}    ${value}
    # click add
    Click Element    xpath=//button[text()="Add"]
    # wait for Add new variable dialog
    Wait Until Element Is Visible    css=section.io-reconquest-snake-env-variables__dialog
    # input name
    Input Text    css=div.aui-dialog2-content input    ${name}
    # input value
    Input Text    css=div.aui-dialog2-content textarea    ${value}
    # save
    Click Element    xpath=//button[text()="Save"]
    # wait for dialog disappear
    Wait Until Element Is Not Visible    css=section.io-reconquest-snake-env-variables__dialog
    # verify variable

Delete A Var In Setting
    [Arguments]    ${name}
    # mouse over the variable
    Mouse Over    xpath=//td/tt[text()="${name}"]
    # wait for remove btn and click
    Wait Until Element Is Visible    xpath=//span[text()="Remove Variable"]
    Click Element    xpath=//span[text()="Remove Variable"]
    # wait for confirm and click Yes
    Wait Until Element Is Visible    xpath=//*[@aria-hidden="false"]//button[text()="No, cancel"]
    Click Element    xpath=//*[@aria-hidden="false"]//button[text()="Yes"]
    # wait for no variable
    Wait Until Element Is Not Visible    xpath=//td/tt[text()="${name}"]

Add A Project Variable
    [Arguments]    ${name}    ${value}
    Go To    ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/settings/env/
    # wait for add button
    Wait Until Element Is Visible    xpath=//button[text()="Add"]
    # try to delete
    Run Keyword And Ignore Error    Delete A Var In Setting    ${name}
    # add
    Add A Var In Setting    ${name}    ${value}

Add A Repo Variable
    [Arguments]    ${name}    ${value}
    Go To    ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/repos/${REPO}/settings/env/
    # wait for add button
    Wait Until Element Is Visible    xpath=//button[text()="Add"]
    # try to delete
    Run Keyword And Ignore Error    Delete A Var In Setting    ${name}
    # add
    Add A Var In Setting    ${name}    ${value}

Delete A Project Variable
    [Arguments]    ${name}    ${value}
    Go To    ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/settings/env/
    # wait for add button
    Wait Until Element Is Visible    xpath=//button[text()="Add"]
    # delete
    Delete A Var In Setting    ${name}

Delete A Repo Variable
    [Arguments]    ${name}    ${value}
    Go To    ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/repos/${REPO}/settings/env/
    # wait for add button
    Wait Until Element Is Visible    xpath=//button[text()="Add"]
    # delete
    Delete A Var In Setting    ${name}

Delete All Project Variable
    Go To    ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/settings/env/
    # wait for add button
    Wait Until Element Is Visible    xpath=//button[text()="Add"]
    # get a list of var name
    ${variables}    Get WebElements    xpath=//table//tbody/tr/td[1]/tt
    @{names}    Create List
    :FOR    ${var}    IN    @{variables}
    \    ${name}    Get Text    ${var}
    \    Append To List    ${names}    ${name}
    # delete all
    :FOR    ${name}    IN    @{names}
    \    Delete A Var In Setting    ${name}

Delete All Repo Variable
    Go To    ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/repos/${REPO}/settings/env/
    # wait for add button
    Wait Until Element Is Visible    xpath=//button[text()="Add"]
    # get a list of var name
    ${variables}    Get WebElements    xpath=//table//tbody/tr/td[1]/tt
    @{names}    Create List
    :FOR    ${var}    IN    @{variables}
    \    ${name}    Get Text    ${var}
    \    Append To List    ${names}    ${name}
    # delete all
    :FOR    ${name}    IN    @{names}
    \    Delete A Var In Setting    ${name}

Delete All Variables
    Delete All Project Variable
    Delete All Repo Variable

## others (will move to different files)


Go To Pipeline Tab And Verify A Pipeline
    [Arguments]    ${url}    ${pipeline_no}    ${status}    ${name}    ${pipeline_num}
    Go To    ${url}
    Click Element    css=a[id="io.reconquest.snake.pull-request.ci.tab.pipelines"]
    Wait Until Element Is Visible    css=div.io-reconquest-snake-pipelines
    # verify status
    Wait Until Element Contains    xpath=//tbody/tr[${pipeline_no}]//span[@class="io-reconquest-status-badge__text"]    ${status}
    # verify pipeline name
    Wait Until Element Contains    xpath=//tbody/tr[${pipeline_no}]//a[@title]    ${name}
    # verify pipeline number
    Wait Until Element Contains    xpath=//tbody/tr[${pipeline_no}]//span[@class="io-reconquest-snake-pipelines__item-id"]    ${pipeline_num}

Click A Pipeline In Pipeline Tab And Verify Pipeline Detail
    [Arguments]    ${pipeline_no}    ${status}    ${name}    ${total_job}    ${pipeline_num}
    # click pipeline
    Click Element    xpath=//tbody/tr[${pipeline_no}]//a[@title]
    Wait Until Element Is Visible    css=div.io-reconquest-snake-pipeline-details__overview-left span.io-reconquest-status-badge__text    ${TIME_OUT}
    # verify its detail
    Verify A Pipeline Detail Page    ${status}    ${name}    ${total_job}    ${pipeline_num}

Merge Pull Request
    [Arguments]    ${pull_id}    ${name}=None    ${delete_branch}=False
    Click Element    xpath=//header//button[text()="Merge"]
    # wait for Merge Pull Request dialog
    Wait Until Element Is Visible    css=section#pull-request-merge-dialog
    # verify the default text
    ${default_name}    Get Text    css=section#pull-request-merge-dialog span[role]
    Should Contain    ${default_name}    Merge pull request #${pull_id} in ${PROJ}/${REPO} from ${BRANCH_NAME} to master
    # change name
    # check for delete branch
    # click Merge
    Click Element    xpath=//section[@id="pull-request-merge-dialog"]//button[text()="Merge"]
    Wait Until Element Is Not Visible    css=section#pull-request-merge-dialog
    # verify merge successful
    Wait Until Element Is Visible    xpath=//div[text()="Merged"]
