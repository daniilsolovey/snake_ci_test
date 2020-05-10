*** Settings ***
Resource    settings.robot
Resource    commonWeb.robot

*** Keywords ***
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

Cancel A Running Pipeline In Pipeline Detail Page
    Wait Until Element Contains    css=div.io-reconquest-snake-pipeline-details__overview-left span.io-reconquest-status-badge__text    Running    ${TIME_OUT}
    Click Element    xpath=//button[text()="Cancel"]

Cancel A Running Job In Pipeline Detail Page
    [Arguments]    ${job_no}
    Wait Until Element Contains    css=table.io-reconquest tbody tr:nth-child(${job_no}) span.io-reconquest-status-badge__text    Running    ${TIME_OUT}
    # hover to the job
    Mouse Over    css=table.io-reconquest tbody tr:nth-child(${job_no}) span.io-reconquest-status-badge__text
    Click Element    xpath=//tbody//tr[${job_no}]//span[text()="Cancel Job"]
