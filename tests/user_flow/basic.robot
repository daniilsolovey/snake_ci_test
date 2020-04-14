*** Settings ***
Resource    ../common.robot
Resource    ../commonWeb.robot
Resource    ../commonGit.robot
Resource    ../commonBitbucket.robot
Resource    ../settings.robot

Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown

Force Tags    basic
Test Timeout    2 minutes
*** Variables ***

*** Test Cases ***
Pipeline is triggered after a push from master
    Set Test Variable    ${COMMIT_MSG}    basic commit
    # push a new yaml file
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/basic.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    Verify basic.yaml Pipeline Detail Page    ${url}

Pipeline is trigger after a push from a branch
    [Tags]    wip
    Set Test Variable    ${COMMIT_MSG}    commit from a branch
    Set Test Variable    ${BRANCH_NAME}    mybranch1
    # push a new yaml file
    ${url}    Copy File To Repo And Push On A Branch    mybranch1    ${EXECDIR}/files/basic.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    Verify basic.yaml Pipeline Detail Page    ${url}
    # create a pull request
    ${pull_url}    Create Pull Request    ${ENCODE_URI}    ${PROJ}    ${REPO}    ${BRANCH_NAME}
    # verify pull request
    Verify Pull Request    ${pull_url}

#Pipeline has last commit name

#Pipeline will fail when a job fails

*** Keywords ***
Verify basic.yaml Pipeline Detail Page
    [Arguments]    ${url}
    Go To    ${url}
    ${num}    Get Pipeline Number From Url    ${url}
    ${id}    Get Short Commit ID
    # verify pipeline status
    Wait Until Element Is Visible    css=div.io-reconquest-snake-pipeline-details__overview-left span.io-reconquest-status-badge__text
    # wait until status is completed
    Wait Until Element Contains    css=div.io-reconquest-snake-pipeline-details__overview-left span.io-reconquest-status-badge__text    Completed    ${TIME_OUT}
    # verify pipeline number
    Element Should Contain    css=div.io-reconquest-snake-pipeline-details h2    Pipeline #${num.strip()}
    # verify pipeline name
    Element Text Should Be    css=div.io-reconquest-snake-pipeline-details__overview-left-info-commit-details p    ${COMMIT_MSG}
    # verify commit id
    Element Text Should Be    css=div.io-reconquest-snake-pipeline-details__overview-left-info-commit-details tt    ${id}
    # verify branch
    # verify total job
    Wait Until Element Contains    css=h3.io-reconquest-snake-pipeline-details__overview-right-jobs-total     Jobs (3 total):3 completed
    # verify total job status
    #Element Text Should Be    css=span.io-reconquest-snake-pipeline-details__overview-right-jobs-total-success     3 completed
    # verify first job
    Verify Job Detail    1    echo $PIPELINE_WIDE\navailable for all jobs    echo "test1"\ntest1
    # verify second job
    Verify Job Detail    2    echo $PIPELINE_WIDE\noverride this var
    # verify third job
    Verify Job Detail    3    echo $BUILD_FOO\nfoo; only for build

Verify Job Detail
    [Documentation]    Verify a job consistant between job detail view an job list based on job_no. Verify it contains text
    [Arguments]    ${job_no}    @{text}
    # click the job_no
    Click Element    css=table.io-reconquest tbody tr:nth-child(${job_no})
    # wait for job detail
    Wait Until Element Is Visible    css=div.io-reconquest-snake-pipeline-details__job
    # verify status
    ${job_status1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) span.io-reconquest-status-badge__text
    ${job_status2}    Get Text    css=div.io-reconquest-snake-pipeline-details__job-details span.io-reconquest-status-badge__text
    Should Be Equal    ${job_status1}    ${job_status2}
    # verify stage
    ${stage1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) span.io-reconquest-snake-jobs__item-stage
    ${stage2}    Get Text    css=div.io-reconquest-snake-pipeline-details__job-details span.io-reconquest-snake-pipeline-details__job-details-stage
    Should Be Equal    ${stage1}    ${stage2}
    # verify job name
    ${name1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) td:nth-child(2) span:nth-child(2)
    ${name2}    Get Text    xpath=//td[text()="Job"]/following-sibling::td
    Should Be Equal    ${name1}    ${name2}
    # verify job id
    ${id1}    Get Text    css=table.io-reconquest tbody tr:nth-child(${job_no}) td:nth-child(2) span:nth-child(3)
    ${id2}    Get Text    xpath=//td[text()="ID"]/following-sibling::td
    Should Be Equal    ${id1}    ${id2}
    # verify log text
    :FOR    ${txt}    IN    @{text}
    \    Element Should Contain    css=div.io-reconquest-snake-pipeline-details__job-logs    ${txt}

Verify basic.yaml Pull Request
    [Arguments]    ${url}
    Go To    ${url}
    ${id}    Get Short Commit ID
    Click Element    css=a[id="io.reconquest.snake.pull-request.ci.tab.pipelines"]
    Wait Until Element Is Visible    css=div.io-reconquest-snake-pipelines
    # wait for status completed
    Wait Until Element Contains    css=span.io-reconquest-status-badge__text    Completed    ${TIME_OUT}
    # verify pipeline name
    Element Text Should Be    xpath=//a[contains(@href,"pipelines/")][@title]    ${COMMIT_MSG}
    # verify commit id
    Element Text Should Be    css=span.io-reconquest-ref-link tt    ${id}
    # verify pipeline number
    # verify avata
    # verify merge button
    # click a pipeline to verify its details


