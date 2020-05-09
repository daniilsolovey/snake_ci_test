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

Go To Pipeline Detail Page
    [Arguments]    ${url}
    Go To    ${url}
    ${num}    Get Pipeline Number From Url    ${url}
    # wait for page loaded
    Wait Until Element Is Visible    css=div.io-reconquest-snake-pipeline-details__overview-left span.io-reconquest-status-badge__text    ${TIME_OUT}
    [Return]    ${num.strip()}

Verify A Pipeline Detail Page
    [Arguments]    ${status}    ${name}    ${total_job}    ${pipeline_num}
    # wait until reaching expected status
    Wait Until Element Contains    css=div.io-reconquest-snake-pipeline-details__overview-left span.io-reconquest-status-badge__text    ${status}    ${TIME_OUT}
    # verify pipeline name
    Element Text Should Be    css=div.io-reconquest-snake-pipeline-details__overview-left-info-commit-details p    ${name}
    # verify total job
    Wait Until Element Contains    css=h3.io-reconquest-snake-pipeline-details__overview-right-jobs-total     ${total_job}
    # verify pipeline number
    Element Should Contain    css=div.io-reconquest-snake-pipeline-details h2    Pipeline #${pipeline_num}

Verify A Pipeline Detail Page With Error In Yaml File
    [Arguments]    ${name}    ${title}    ${msg}    ${pipeline_num}
    # wait until status Failed
    Wait Until Element Contains    css=div.io-reconquest-snake-pipeline-details__overview-left span.io-reconquest-status-badge__text    Failed    ${TIME_OUT}
    # verify pipeline name
    Element Text Should Be    css=div.io-reconquest-snake-pipeline-details__overview-left-info-commit-details p    ${name}
    # verify msg
    Element Text Should Be    css=p.title    ${title}
    Element Text Should Be    css=p.io-reconquest-snake-pipeline-details__overview-right-error-message    ${msg}
    # verify pipeline number
    Element Should Contain    css=div.io-reconquest-snake-pipeline-details h2    Pipeline #${pipeline_num}

Go To Pipeline List Page And Verify A Pipeline
    [Arguments]    ${pipeline_no}    ${status}    ${name}    ${pipeline_num}
    Go To     ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/repos/${REPO}/pipelines/
    # wait for loaded
    Wait Until Element Is Visible    css=table.io-reconquest    ${TIME_OUT}
    # verify status
    Wait Until Element Contains    xpath=//tbody/tr[${pipeline_no}]//span[@class="io-reconquest-status-badge__text"]    ${status}    ${TIME_OUT}
    # verify pipeline name
    Wait Until Element Contains    xpath=//tbody/tr[${pipeline_no}]//a[@title]    ${name}
    # verify pipeline number. Use Page Should Contain Element in case the pipeline name is long and overlap the number
    Page Should Contain Element    xpath=//tbody/tr[${pipeline_no}]/td[3]//span[text()="#${pipeline_num}"]

Go To Job List Page And Verify A Job
    [Arguments]    ${job_no}    ${status}    ${pipeline}    ${job_stage}    ${job_name}    ${pipeline_num}
    Go To     ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/repos/${REPO}/jobs/
    Wait Until Element Is Visible    css=table.io-reconquest    ${TIME_OUT}
    # verify job status
    Wait Until Element Contains    xpath=//tbody/tr[${job_no}]//span[@class="io-reconquest-status-badge__text"]    ${status}    ${TIME_OUT}
    # verify pipeline
    Wait Until Element Contains    xpath=//tbody/tr[${job_no}]/td[3]//a[@title]    ${pipeline}
    # verify job stage
    Wait Until Element Contains    xpath=//tbody/tr[${job_no}]/td[4]//span[1]    ${job_stage}
    # verify job name
    Wait Until Element Contains    xpath=//tbody/tr[${job_no}]/td[4]//a    ${job_name}
    # verify pipeline_num. Use Page Should Contain Element in case the pipeline name is long and overlap the number
    Page Should Contain Element    xpath=//tbody/tr[${job_no}]/td[3]//span[text()="#${pipeline_num}"]

Go To Job List Page And Verify No Job From A Pipeline
    [Arguments]    ${pipeline_num}
    Go To     ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/repos/${REPO}/jobs/
    Wait Until Element Is Visible    css=table.io-reconquest    ${TIME_OUT}
    # verify pipeline_num. Use Page Should Not Contain Element in case the pipeline name is long and overlap the number
    Page Should Not Contain Element    xpath=//span[text()="#${pipeline_num}"]

Verify A Job In Pipeline Detail Page With Log
    [Documentation]    Verify a job in pipelien detail page
    [Arguments]    ${job_no}    ${job_status}   ${stage}   ${job_name}
    # click the job_no
    Click Element    css=table.io-reconquest tbody tr:nth-child(${job_no})
    # wait for job detail
    Wait Until Element Is Visible    css=div.io-reconquest-snake-pipeline-details__job
    # verify status
    ${job_status1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) span.io-reconquest-status-badge__text
    Should Be Equal    ${job_status1}    ${job_status}
    ${job_status2}    Get Text    css=div.io-reconquest-snake-pipeline-details__job-details span.io-reconquest-status-badge__text
    Should Be Equal    ${job_status2}    ${job_status}
    # verify stage
    ${stage1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) span.io-reconquest-snake-jobs__item-stage
    Should Be Equal    ${stage1}    ${stage}
    ${stage2}    Get Text    css=div.io-reconquest-snake-pipeline-details__job-details span.io-reconquest-snake-pipeline-details__job-details-stage
    Should Be Equal    ${stage2}    ${stage}
    # verify job name
    ${job_name1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) td:nth-child(2) span:nth-child(2)
    Should Be Equal    ${job_name1}    ${job_name}
    ${job_name2}    Get Text    xpath=//td[text()="Job"]/following-sibling::td
    Should Be Equal    ${job_name2}    ${job_name}
    # verify job id matching
    ${id1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) td:nth-child(2) span:nth-child(3)
    ${id2}    Get Text    xpath=//td[text()="ID"]/following-sibling::td
    Should Be Equal    ${id1}    ${id2}

Verify A Job In Pipeline Detail Page Without Log
    [Documentation]    Verify a job in pipelien detail page
    [Arguments]    ${job_no}    ${job_status}   ${stage}   ${job_name}
    # verify status
    ${job_status1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) span.io-reconquest-status-badge__text
    Should Be Equal    ${job_status1}    ${job_status}
    # verify stage
    ${stage1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) span.io-reconquest-snake-jobs__item-stage
    Should Be Equal    ${stage1}    ${stage}
    # verify job name
    ${job_name1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) td:nth-child(2) span:nth-child(2)
    Should Be Equal    ${job_name1}    ${job_name}

Verify A Job In Pipeline Detail Page
    [Documentation]    Verify a job in pipelien detail page
    [Arguments]    ${job_no}    ${job_status}   ${stage}   ${job_name}   @{text}
    ${length}    Get Length    ${text}
    Run Keyword If    ${length} == 0    Verify A Job In Pipeline Detail Page Without Log    ${job_no}    ${job_status}   ${stage}   ${job_name}
    ...    ELSE    Verify A Job In Pipeline Detail Page With Log    ${job_no}    ${job_status}   ${stage}   ${job_name}
    :FOR    ${txt}    IN    @{text}
    \    Element Should Contain    css=div.io-reconquest-snake-pipeline-details__job-logs    ${txt}

Verify A Job In Pipeline Detail Page With Regex
    [Documentation]    Verify a job in pipelien detail page
    [Arguments]    ${job_no}    ${job_status}   ${stage}   ${job_name}   @{text}
    Verify A Job In Pipeline Detail Page With Log    ${job_no}    ${job_status}   ${stage}   ${job_name}
    # verify log text
    ${log}    Get Text    css=div.io-reconquest-snake-pipeline-details__job-logs
    log    ${log}
    :FOR    ${txt}    IN    @{text}
    \    Should Match Regexp    ${log}    ${txt}

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

Invoke A New Pipeline
    [Arguments]    ${branch}    ${name}    ${value}
    Go To     ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/repos/${REPO}/pipelines/
    # wait for loaded
    Wait Until Element Is Visible    css=table.io-reconquest    ${TIME_OUT}
    # Click New pipeline
    Click Element    xpath=//button[text()="New pipeline"]
    # wait for dialog
    Wait Until Element Is Visible    css=section.io-reconquest-snake-run-pipeline-dialog
    # click to open dropbox
    Click Element    css=div.aui-select2-container span.select2-arrow
    Wait Until Keyword Succeeds    ${TIME_OUT}    1s    Element Attribute Contains    css=div.select2-drop    style    display: block
    # select branch/tag
    Wait Until Element Is Visible    xpath=//li/div[contains(text(),"${branch}")]
    Click Element    xpath=//li/div[contains(text(),"${branch}")]
    # wait for dropbox close
    Wait Until Keyword Succeeds    ${TIME_OUT}    1s    Element Attribute Contains    css=div.select2-drop    style    display: none
    # input var name
    Input Text    xpath=//div/div[1]/input[@placeholder="Variable name"]    ${name}
    # input var value
    Input Text    xpath=//div/div[1]/input[@placeholder="Variable name"]/following-sibling::textarea    ${value}
    # click run
    Click Element    xpath=//button[text()="Run"]
    # wait for no dialog
    Wait Until Element Is Not Visible    css=section.io-reconquest-snake-run-pipeline-dialog

Invoke A New Pipeline And Verify Error
    [Arguments]    ${branch}    ${name}    ${value}    ${msg}
    Go To     ${BASE_URL}/plugins/servlet/snake-ci/projects/${PROJ}/repos/${REPO}/pipelines/
    # wait for loaded
    Wait Until Element Is Visible    css=table.io-reconquest    ${TIME_OUT}
    # Click New pipeline
    Click Element    xpath=//button[text()="New pipeline"]
    # wait for dialog
    Wait Until Element Is Visible    css=section.io-reconquest-snake-run-pipeline-dialog
    # click to open dropbox
    Click Element    css=div.aui-select2-container span.select2-arrow
    Wait Until Keyword Succeeds    ${TIME_OUT}    1s    Element Attribute Contains    css=div.select2-drop    style    display: block
    # select branch/tag
    Wait Until Element Is Visible    xpath=//li/div[contains(text(),"${branch}")]
    Click Element    xpath=//li/div[contains(text(),"${branch}")]
    # wait for dropbox close
    Wait Until Keyword Succeeds    ${TIME_OUT}    1s    Element Attribute Contains    css=div.select2-drop    style    display: none
    # input var name
    Input Text    xpath=//div/div[1]/input[@placeholder="Variable name"]    ${name}
    # input var value
    Input Text    xpath=//div/div[1]/input[@placeholder="Variable name"]/following-sibling::textarea    ${value}
    # click run
    Click Element    xpath=//button[text()="Run"]
    # wait for error message
    Wait Until Element Is Not Visible    css=section.io-reconquest-snake-run-pipeline-dialog div.aui-message-error p
    Wait Until Element Contains    css=section.io-reconquest-snake-run-pipeline-dialog div.aui-message-error p    ${msg}

Element Attribute Contains
    [Arguments]    ${element}    ${attribute}    ${value}
    ${value_full}    Get Element Attribute    ${element}    ${attribute}
    Should Contain    ${value_full}    ${value}


