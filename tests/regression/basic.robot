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
Pipeline is triggered after a push from master
    Set Test Variable    ${COMMIT_MSG}    basic commit
    # push a new yaml file
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/basic.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (3 total):3 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    install dependencies    echo $PIPELINE_WIDE\navailable for all jobs    echo "test1"\ntest1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    unit tests 1    echo $PIPELINE_WIDE\noverride this var
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    unit tests 2    echo $BUILD_FOO\nfoo; only for build
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    install dependencies    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE2    unit tests 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE2    unit tests 2    ${pipeline_num}

Pipeline is trigger after a push from a branch
    Set Test Variable    ${COMMIT_MSG}    commit from a branch
    Set Test Variable    ${BRANCH_NAME}    mybranch1
    # dete mybranch1
    Delete Local And Remote Branch And Ignore Failure    ${BRANCH_NAME}
    # push a new yaml file
    ${url}    Copy File To Repo And Push On A Branch    ${BRANCH_NAME}    ${EXECDIR}/files/basic.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (3 total):3 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    install dependencies    echo $PIPELINE_WIDE\navailable for all jobs    echo "test1"\ntest1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    unit tests 1    echo $PIPELINE_WIDE\noverride this var
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    unit tests 2    echo $BUILD_FOO\nfoo; only for build
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    install dependencies    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE2    unit tests 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE2    unit tests 2    ${pipeline_num}
    # create a pull request
    ${pull_url}    Create Pull Request    ${ENCODE_URI}    ${PROJ}    ${REPO}    ${BRANCH_NAME}
    ${pull_id}    Get Pull request ID From Url    ${pull_url}
    # verify pipeline in pull request tab
    Go To Pipeline Tab And Verify A Pipeline    ${pull_url}    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # click a pipeline and verify detail
    Click A Pipeline In Pipeline Tab And Verify Pipeline Detail    1    Completed    ${COMMIT_MSG}    Jobs (3 total):3 completed    ${pipeline_num}
    # verify pipeline tab
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    install dependencies    echo $PIPELINE_WIDE\navailable for all jobs    echo "test1"\ntest1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    unit tests 1    echo $PIPELINE_WIDE\noverride this var
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    unit tests 2    echo $BUILD_FOO\nfoo; only for build
    # merge the request
    Merge Pull Request    ${pull_id}    None    False
    # calculate next pipeline num
    ${pipeline_int}    Convert To Integer    ${pipeline_num}
    ${next_pipeline}    Convert To String    ${pipeline_int + 1}
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    Merge pull request #${pull_id} in ${PROJ}/${REPO} from ${BRANCH_NAME} to master    ${next_pipeline}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    Merge pull request #${pull_id} in ${PROJ}/${REPO} from ${BRANCH_NAME} to master    STAGE1    install dependencies    ${next_pipeline}
    Go To Job List Page And Verify A Job    2    Completed    Merge pull request #${pull_id} in ${PROJ}/${REPO} from ${BRANCH_NAME} to master    STAGE2    unit tests 1    ${next_pipeline}
    Go To Job List Page And Verify A Job    3    Completed    Merge pull request #${pull_id} in ${PROJ}/${REPO} from ${BRANCH_NAME} to master    STAGE2    unit tests 2    ${next_pipeline}
    # verify pipeline in pipeline tab
    Go To Pipeline Tab And Verify A Pipeline    ${pull_url}    1    Completed    Merge pull request #${pull_id} in ${PROJ}/${REPO} from ${BRANCH_NAME} to master    ${next_pipeline}
    # click a pipeline and verify detail
    Click A Pipeline In Pipeline Tab And Verify Pipeline Detail    1    Completed    Merge pull request #${pull_id} in ${PROJ}/${REPO} from ${BRANCH_NAME} to master    Jobs (3 total):3 completed    ${next_pipeline}
    # verify pipeline tab
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    install dependencies    echo $PIPELINE_WIDE\navailable for all jobs    echo "test1"\ntest1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    unit tests 1    echo $PIPELINE_WIDE\noverride this var
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    unit tests 2    echo $BUILD_FOO\nfoo; only for build

Invoke New Pipeline On Web UI From A Branch
    Set Test Variable    ${COMMIT_MSG}    Invoke pipeline from web test
    Set Test Variable    ${TAG_NAME}    webInvoke
    Set Test Variable    ${BRANCH}    master
    # push a new yaml file
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/basic.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (3 total):3 completed    ${pipeline_num}
    # delete the tag on master
    Delete Local And Remote Tag On A Branch And Ignore Failure    ${BRANCH}    ${TAG_NAME}
    # add tag to latest commit on master
    ${url}    Add Tag To Master    ${TAG_NAME}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${commit_msg}    Jobs (3 total):3 completed    ${pipeline_num}
    # invoke the pipeline with tag on web. Variable not in use
    Invoke A New Pipeline    ${BRANCH}    xxx    yyy
    # verify pipeline detail page
    ${pipeline_int}    Convert To Integer    ${pipeline_num}
    ${next_pipeline}    Convert To String    ${pipeline_int + 1}
    Verify A Pipeline Detail Page    Completed    ${commit_msg}    Jobs (3 total):3 completed    ${next_pipeline}

Pipeline has last commit name
    Set Test Variable    ${COMMIT_MSG1}    commit message 1
    Set Test Variable    ${COMMIT_MSG2}    commit message 2
    # push a new yaml file
    ${url}    Copy File To Repo And Push 2    ${EXECDIR}/files/basic1.yaml    ${SNAKE_YAML}    ${COMMIT_MSG1}    ${COMMIT_MSG2}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Failed    ${COMMIT_MSG2}    Jobs (3 total):1 failed2 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    install dependencies    echo test install\ntest install
    Verify A Job In Pipeline Detail Page    2    Failed    STAGE2    unit tests 1    command failed
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    unit tests 2    echo test 2\ntest 2
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG2}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG2}    STAGE1    install dependencies    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Failed    ${COMMIT_MSG2}    STAGE2    unit tests 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG2}    STAGE2    unit tests 2    ${pipeline_num}

Pipeline will fail when a job fails
    Set Test Variable    ${COMMIT_MSG}    test failed pipeline
    # push a new yaml file
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/basic1.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Failed    ${COMMIT_MSG}    Jobs (3 total):1 failed2 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    install dependencies    echo test install\ntest install
    Verify A Job In Pipeline Detail Page    2    Failed    STAGE2    unit tests 1    command failed
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    unit tests 2    echo test 2\ntest 2
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    install dependencies    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Failed    ${COMMIT_MSG}    STAGE2    unit tests 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE2    unit tests 2    ${pipeline_num}

*** Keywords ***


