*** Settings ***
Resource          settings.robot

*** Keywords ***
Common Test Setup
    sleep    1s

Common Test Teardown
    Terminate All Processes
    #Delete Local And Remote Branch And Ignore Failure    mybranch1

Common Suite Setup
    ${REPO_URL}    Get Repo Url
    ${PROJECT_URL}    Get Project Url
    Set Suite Variable    ${REPO_URL}
    Set Suite Variable    ${PROJECT_URL}
    Go To Url And Login    ${REPO_URL}    ${ADMIN_USER}    ${ADMIN_PWD}
    # delete local repo
    # delete remote project / repo
    # create remote project / repo
    # clone repo
    Delete Local And Remote Branch And Ignore Failure    mybranch1

Common Suite Teardown
    Close All Browsers

Run Process Wrapper
    [Arguments]    @{args}    &{dic_args}
    ${result}    Run Process    @{args}    &{dic_args}
    Log Many	stdout: ${result.stdout}	stderr: ${result.stderr}
    [Return]    ${result}

Get Log Line Count
    [Arguments]    ${log_path}
    ${content}    Read File From Container    ${CONTENER}    ${log_path}
    ${line_num}    Get Line Count    ${content}
    [Return]    ${line_num}

Get Log From Start To End
    [Arguments]    ${log_path}    ${start}    ${end}
    ${content}    Read File From Container    ${CONTENER}    ${log_path}
    ${test_log}    Split To Lines    ${content}    ${start}    ${end}
    ${log}    Evaluate    str(${test_log})
    ${error}    Run Keyword And Return Status    Should Contain    ${log}    ERROR
    Run Keyword If    ${error}    Log    ${log}    level=WARN
    ...    ELSE    Log    ${log}
    [Return]    ${test_log}

Get Pipeline Url
    [Arguments]    ${text}
    ${line}    Get Lines Containing String    ${text}    ${BASE_URL}/plugins/servlet/snake-ci
    ${url}    Get Regexp Matches    ${line}    http.*$
    [Return]    @{url}[0]

Get Pull Request Url
    [Arguments]    ${text}
    ${line}    Get Lines Containing String    ${text}    pull-requests?create&sourceBranch=refs/heads
    ${url}    Get Regexp Matches    ${line}    http.*$
    [Return]    @{url}[0]

Get Pipeline Number From Url
    [Arguments]    ${url}
    @{list}    Split String    ${url}    /
    [Return]    @{list}[-1]