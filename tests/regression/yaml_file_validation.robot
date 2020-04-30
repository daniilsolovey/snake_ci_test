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
Stage Is Require In Yaml File
    [Tags]    zzz
    ## verify stage is require
    Set Test Variable    ${COMMIT_MSG}    validate yaml file 1
    # verify stage is require
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_validation1.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page With Error In Yaml File    ${COMMIT_MSG}    Unable to run pipeline due to errors in snake-ci.yaml file    Job "install dependencies": stage field is not specified. No stages defined.    ${pipeline_num.strip()}
    # verify in the pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG}    ${pipeline_num}
    # verify in the job list page
    Go To Job List Page And Verify No Job From A Pipeline    ${pipeline_num}

Image Is Optional In Yaml File
    [Tags]    zzz
    Set Test Variable    ${COMMIT_MSG}    validate yaml file 4
    # verify stage is require
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_validation4.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (3 total):3 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    install dependencies    Using docker image: alpine:latest
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    unit tests 1    Using docker image: golang:latest
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    unit tests 2    Using docker image: maven:3
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    install dependencies    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE2    unit tests 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE2    unit tests 2    ${pipeline_num}

Verify Only Property In Yaml File
    [Tags]    zzz
    ### push on branch1
    Set Test Variable    ${COMMIT_MSG}    validate yaml file 5 from branch1
    Set Test Variable    ${BRANCH_NAME}    branch1
    # delete the branch
    Delete Local And Remote Branch And Ignore Failure    ${BRANCH_NAME}
    # push a new yaml file
    ${url}    Copy File To Repo And Push On A Branch    ${BRANCH_NAME}    ${EXECDIR}/files/yaml_validation5.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (3 total):3 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    job 3
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    job 4
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE2    job 3    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE2    job 4    ${pipeline_num}
    ### push on tag2
    ${commit_msg}    Get Last Commit Message On Branch    master
    Set Test Variable    ${TAG_NAME}    tag2
    # delete the tag on master
    Delete Local And Remote Tag On A Branch And Ignore Failure    master    ${TAG_NAME}
    # add tag to latest commit on master
    ${url}    Add Tag To Master    ${TAG_NAME}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${commit_msg}    Jobs (2 total):2 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 2
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    job 4
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${commit_msg}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${commit_msg}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${commit_msg}    STAGE2    job 4    ${pipeline_num}

Verify Builtin Environment Variables
    [Tags]    zzz
    Set Test Variable    ${COMMIT_MSG}    verify builtin variables
    # push a new yaml file
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/builtin_variables.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (1 total):1 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page. all var has content will match with ^.+$  . All var has no content will match with ^$
    Verify A Job In Pipeline Detail Page With Regex    1    Completed    STAGE1    install dependencies
    ...    CI_PIPELINE_ID\\n.+
    ...    CI_JOB_ID\\n.+
    ...    CI_JOB_STAGE\\n.+
    ...    CI_JOB_NAME\\n.+
    ...    CI_BRANCH\\n.+
    ...    CI_TAG\\n\\n
    ...    CI_COMMIT_HASH\\n.+
    ...    CI_COMMIT_SHORT_HASH\\n.+
    ...    CI_PIPELINE_DIR\\n.+
    ...    CI_PULL_REQUEST_ID\\n\\n
    ...    CI_PROJECT_KEY\\n.+
    ...    CI_PROJECT_NAME\\n.+
    ...    CI_PROJECT_ID\\n.+
    ...    CI_REPO_SLUG\\n.+
    ...    CI_REPO_NAME\\n.+
    ...    CI_REPO_ID\\n.+
    ...    CI_REPO_CLONE_URL_SSH\\n.+
    ...    CI_RUNNER_ID\\n.+
    ...    CI_RUNNER_NAME\\n.+
    ...    CI_RUNNER_VERSION\\n.+
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    install dependencies    ${pipeline_num}

Verify Variable Levels
    [Tags]    zzz
    ### verify job var > pipeline > dialog > repo > project; pipeline > dialog > repo > project
    ${proj_value}    Set Variable    This is project var
    ${repo_value}    Set Variable    This is repo var
    Set Test Variable    ${COMMIT_MSG}    Verify job and pipeline var
    # add project variable
    Add A Project Variable    TEST    ${proj_value}
    # add repo variable
    Add A Repo Variable    TEST    ${repo_value}
    # push yaml file
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/var_level1.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (2 total):2 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    echo $TEST\nThis is job var
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE1    job 2    echo $TEST\nThis is pipeline var
    ### verify repo > project
    Set Test Variable    ${COMMIT_MSG}    Verify repo var > project var
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/var_level2.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (1 total):1 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    echo $TEST\nThis is job var
    ### verify dialog > repo > prj

*** Keywords ***
