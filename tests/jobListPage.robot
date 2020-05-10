*** Settings ***
Resource          settings.robot

*** Keywords ***
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

Cancel A Running Job In Job List Page
    [Arguments]    ${job_no}
    Wait Until Element Contains    xpath=//tbody/tr[${job_no}]//span[@class="io-reconquest-status-badge__text"]    Running    ${TIME_OUT}
    # hover to pipeline name
    Mouse Over    xpath=//tbody/tr[${job_no}]/td[3]//a[@title]
    Click Element    xpath=//tbody/tr[${job_no}]//span[text()="Cancel Job"]
