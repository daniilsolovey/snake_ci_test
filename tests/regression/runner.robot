*** Settings ***
Resource    ../common.robot
Resource    ../commonWeb.robot
Resource    ../commonGit.robot
Resource    ../commonBitbucket.robot
Resource    ../settings.robot
Resource    ../pipelineDetailPage.robot
Resource    ../pipelineListPage.robot
Resource    ../jobListPage.robot

Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown

Force Tags    basic
Test Timeout    2 minutes
*** Variables ***

*** Test Cases ***
Invalid yaml file name
    ## push
    Set Test Variable    ${COMMIT_MSG}    Verify invalid yaml file name
    Remove Yaml File And Push    ${SNAKE_YAML}    ${COMMIT_MSG}
    ## trigger from new pipelie dialog
    Invoke A New Pipeline And Verify Error    master    xxx    yyy    No YAML config found on the specified git reference.

#Verify Variable Levels
#    ### verify job var > pipeline > dialog > repo > project; pipeline > dialog > repo > project
#    ${proj_value}    Set Variable    This is project var
#    ${repo_value}    Set Variable    This is repo var
#    Set Test Variable    ${COMMIT_MSG}    Verify job and pipeline var
#    # add project variable
#    Add A Project Variable    TEST    ${proj_value}
#    # add repo variable
#    Add A Repo Variable    TEST    ${repo_value}
#    # push yaml file
#    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/var_level1.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
#    # verify pipeline detail page
#    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
#    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (2 total):2 completed    ${pipeline_num}
#    # Verify jobs in pipeline detail page
#    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    echo $TEST\nThis is job var
#    Verify A Job In Pipeline Detail Page    2    Completed    STAGE1    job 2    echo $TEST\nThis is pipeline var
#    ### verify repo > project
#    Set Test Variable    ${COMMIT_MSG}    Verify repo var > project var
#    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/var_level2.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
#    # verify pipeline detail page
#    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
#    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (1 total):1 completed    ${pipeline_num}
#    # Verify jobs in pipeline detail page
#    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    echo $TEST\nThis is job var
#    ### verify dialog > repo > prj

Verify Builtin Environment Variables
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

Cancel a running pipeline
    ## cancel in pipeline detail page
    ${commit_msg}    Set Variable    Verify canceling a running pipeline from pipeline detail page
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/runner_cancel_pipeline.yaml    ${SNAKE_YAML}    ${commit_msg}
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Cancel A Running Pipeline In Pipeline Detail Page
    Verify A Pipeline Detail Page    Canceled    ${commit_msg}    Jobs (1 total):1 canceled    ${pipeline_num}
    Verify A Job In Pipeline Detail Page    1    Canceled    STAGE1    job 1
    ## cancel in pipeline list page
    ${commit_msg}    Set Variable    Verify canceling a running pipeline from pipeline list page
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/runner_cancel_pipeline.yaml    ${SNAKE_YAML}    ${commit_msg}
    ${pipeline_num}    Get Pipeline Number From Url    ${url}
    Go To Pipeline List Page And Verify A Pipeline    1    Running    ${commit_msg}    ${pipeline_num.strip()}
    Cancel A Running Pipeline In Pipeline List Page    1
    Go To Pipeline List Page And Verify A Pipeline    1    Canceled    ${commit_msg}    ${pipeline_num.strip()}

Cancel a running pipeline from a pull request
    # cancel in pipeline detail page
    # cancel in pipeline list

Cancel a running job
    ## cancel in pipeline detail page
    ${commit_msg}    Set Variable    Verify canceling a running job from pipeline detail page
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/runner_cancel_job.yaml    ${SNAKE_YAML}    ${commit_msg}
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Cancel A Running Job In Pipeline Detail Page    1
    Verify A Pipeline Detail Page    Canceled    ${COMMIT_MSG}    Jobs (2 total):2 canceled    ${pipeline_num}
    Verify A Job In Pipeline Detail Page    1    Canceled    STAGE1    job 1
    Verify A Job In Pipeline Detail Page    2    Canceled    STAGE2    job 2
    Go To Job List Page And Verify A Job    1    Canceled    ${commit_msg}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Canceled    ${commit_msg}    STAGE2    job 2    ${pipeline_num}
    ## cancel in job list page
    ${commit_msg}    Set Variable    Verify canceling a running job from job list page
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/runner_cancel_job.yaml    ${SNAKE_YAML}    ${commit_msg}
    ${pipeline_num}    Get Pipeline Number From Url    ${url}
    Go To Job List Page And Verify A Job    1    Running    ${commit_msg}    STAGE1    job 1    ${pipeline_num.strip()}
    Cancel A Running Job In Job List Page    1
    Go To Job List Page And Verify A Job    1    Canceled    ${commit_msg}    STAGE1    job 1    ${pipeline_num.strip()}
    Go To Job List Page And Verify A Job    2    Canceled    ${commit_msg}    STAGE2    job 2    ${pipeline_num.strip()}

*** Keywords ***
