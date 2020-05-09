*** Settings ***
Library    Process
Library    OperatingSystem
Library    String
Library    SeleniumLibrary
Library    Collections

*** Variables ***
# remote repo
${BASE_URL}    http://core.reconquest.io:9680
${PROJ}    PR
${REPO}    repo1
${ENCODE_URI}    http://admin:Aitae%3Fj%3Foar4ra@core.reconquest.io:9680

# admin user
${ADMIN_USER}    admin
${ADMIN_PWD_FILE}    ${EXECDIR}/pwd.txt
${ADMIN_EMAIL}    we@reconquest.io
${ADMIN_PWD}    Aitae?j?oar4ra

# local repo
${REPO_DIR}    /Users/robin/myfl/repo1
${SNAKE_YAML}    ${REPO_DIR}/snake-ci.yaml

# settings
${BROWSER}    chrome
${TIME_OUT}    30 sec