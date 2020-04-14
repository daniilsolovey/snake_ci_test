*** Settings ***
Resource          settings.robot
Resource          common.robot

*** Keywords ***
Copy File To Repo And Push
    [Arguments]    ${sfile}    ${dfile}    ${msg_name}    ${repo_dir}=${REPO_DIR}
    # checkout
    ${result}    Run Process Wrapper    git    checkout    master    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    # copy file
    Copy File    ${sfile}    ${dfile}
    # modify a file incase of no change
    ${result}    Run Process Wrapper    date >> test.txt    shell=yes    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    # push
    ${result}    Run Process Wrapper    git    add    -A    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    ${result}    Run Process Wrapper    git    commit    -m    ${msg_name}    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    ${result}    Run Process Wrapper    git    push    origin    cwd=${repo_dir}
    Should Be Equal As Integers    ${result.rc}    0
    # should contain the pipeline url
    Should Contain    ${result.stderr}    remote: Watch pipeline for master:
    ${url}    Get Pipeline Url    ${result.stderr}
    [Return]    ${url}

Copy File To Repo And Push On A Branch
    [Arguments]    ${branch}    ${sfile}    ${dfile}    ${msg_name}   ${repo_dir}=${REPO_DIR}
    # checkout
    ${result}    Run Process Wrapper    git    checkout    master    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    # pull
    ${result}    Run Process Wrapper    git    pull    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    Should Be Equal    ${result.stdout}    Already up to date.
    # git branch
    ${result}    Run Process Wrapper    git    branch    ${branch}    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    # git checkout branch
    ${result}    Run Process Wrapper    git    checkout    ${branch}    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    Should Be Equal    ${result.stderr}    Switched to branch '${branch}'
    # copy file
    Copy File    ${sfile}    ${dfile}
    # modify a file incase of no change
    ${result}    Run Process Wrapper    date >> test.txt    shell=yes    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    # push
    ${result}    Run Process Wrapper    git    add    -A    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    ${result}    Run Process Wrapper    git    commit    -m    ${msg_name}    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    ${result}    Run Process Wrapper    git    push    --set-upstream    origin    ${branch}    cwd=${repo_dir}
    Should Be Equal    ${result.stdout}    Branch '${branch}' set up to track remote branch '${branch}' from 'origin'.
    Should Contain    ${result.stderr}    ${branch} -> ${branch}
    # should contain the pipeline url
    Should Contain    ${result.stderr}    remote: Create pull request for ${branch}:
    ${pull_url}    Get Pull Request Url    ${result.stderr}
    # should contain the pipeline url
    Should Contain    ${result.stderr}    remote: Watch pipeline for ${branch}:
    ${url}    Get Pipeline Url    ${result.stderr}
    [Return]    ${url}

Delete Local And Remote Branch
    [Arguments]    ${branch}    ${repo_dir}=${REPO_DIR}
    # checkout
    ${result}    Run Process Wrapper    git    checkout    master    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    # delete local branch
    ${result}    Run Process Wrapper    git    branch    -D    ${branch}    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    Should Contain    ${result.stdout}    Deleted branch ${branch}
    # delete remote branch
    ${result}    Run Process Wrapper    git    push    origin    --delete    ${branch}    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    Should Contain    ${result.stderr}    [deleted]
    Should Contain    ${result.stderr}    ${branch}

Delete Local And Remote Branch And Ignore Failure
    [Arguments]    ${branch}    ${repo_dir}=${REPO_DIR}
    ${result}    Run Process Wrapper    git    checkout    master    cwd=${repo_dir}
    #Should Be Equal As Integers	   ${result.rc}	   0
    # delete local branch
    ${result}    Run Process Wrapper    git    branch    -D    ${branch}    cwd=${repo_dir}
    # delete remote branch
    ${result}    Run Process Wrapper    git    push    origin    --delete    ${branch}    cwd=${repo_dir}

Checkout Repo To Local
    [Arguments]    ${url}    ${user}
    ${result}    Run Process Wrapper    git    clone    ${url}    cwd=${repo_dir}

Get Short Commit ID
    [Arguments]    ${repo_dir}=${REPO_DIR}
    ${result}    Run Process Wrapper    git    rev-parse    --short    HEAD    cwd=${repo_dir}
    Should Be Equal As Integers	   ${result.rc}	   0
    [Return]    ${result.stdout}
