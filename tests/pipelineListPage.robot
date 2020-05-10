*** Settings ***
Resource          settings.robot

*** Keywords ***
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

Cancel A Running Pipeline In Pipeline List Page
    [Arguments]    ${pipeline_no}
    Wait Until Element Contains    xpath=//tbody/tr[${pipeline_no}]//span[@class="io-reconquest-status-badge__text"]    Running    ${TIME_OUT}
    # hover to pipeline name
    Mouse Over    xpath=//tbody/tr[${pipeline_no}]//a[@title]
    #Click Element    xpath=//tbody/tr[1]//span[text()="Retry Pipeline"]
    Click Element    xpath=//tbody/tr[${pipeline_no}]//span[text()="Cancel Pipeline"]
