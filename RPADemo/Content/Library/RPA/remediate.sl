namespace: RPA
flow:
  name: remediate
  inputs:
    - sys_id
    - incident_number
    - incident_short_desc
    - portal_url
    - portal_user
    - portal_password
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
  workflow:
    - incident_state_in_progress:
        do:
          SNOW.update_incident:
            - host: "${get_sp('serviceNow.instance_name')}"
            - api_version: /v1
            - sys_id: '${sys_id}'
            - auth_type: Basic
            - username: "${get_sp('serviceNow.username')}"
            - password:
                value: "${get_sp('serviceNow.password')}"
                sensitive: true
            - incident_state: In Progress
            - request_body: "${'{\\'state\\':\\'' + incident_state +'\\'}'}"
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password: '${proxy_password}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: execute_leanFT_script
    - notify_slack:
        do:
          Slack.post_message:
            - message: "${'Incident <https://dev51977.service-now.com/nav_to.do?uri=incident.do?sys_id=' + sys_id + '|' + incident_number + ' - ' + incident_short_desc + '> was resolved. \\\\n *Resolution notes:* ' + close_notes + '\\''}"
            - token:
                value: "${get_sp('chatops.token')}"
                sensitive: true
            - channel: "${get_sp('chatops.channel')}"
        navigate:
          - FAILURE: SUCCESS
          - SUCCESS: SUCCESS
    - incident_state_resolved:
        do:
          SNOW.update_incident:
            - host: "${get_sp('serviceNow.instance_name')}"
            - api_version: /v1
            - sys_id: '${sys_id}'
            - auth_type: Basic
            - username: "${get_sp('serviceNow.username')}"
            - password:
                value: "${get_sp('serviceNow.password')}"
                sensitive: true
            - incident_state: Resolved
            - close_code: Solved (Permanently)
            - close_notes: "${'Reset password for user: ' + portal_user + '.'}"
            - request_body: "${'{\\'state\\':\\'' + incident_state +'\\', \\'close_code\\':\\'' + close_code + '\\', \\'close_notes\\':\\'' + close_notes + '\\' }'}"
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password: '${proxy_password}'
        publish:
          - close_notes
        navigate:
          - FAILURE: on_failure
          - SUCCESS: atach_file
    - execute_leanFT_script:
        do:
          RPA.execute_script:
            - host: "${get_sp('leanFT.host')}"
            - protocol: http
            - port: '5985'
            - username: "${get_sp('leanFT.user')}"
            - password: "${get_sp('leanFT.password')}"
            - script: "${'& \"C:\\Program Files (x86)\\NUnit.org\\\\nunit-console\\\\nunit3-console.exe\" C:\\Users\\Administrator\\Desktop\\RPA_Demo_Tests\\RPADemo_Test\\RPADemo_Test\\\\bin\\Release\\RPADemo_Test.dll --test=RPADemo_Test.RPADemo_Cases.LoginUseCase --params=\"BrowserType=Chrome;URL=' + portal_url + ';UserName=' + portal_user + ';Password='+ portal_password +'\"'}"
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password: '${proxy_password}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: incident_state_resolved
    - atach_file:
        do:
          SNOW.atach_file:
            - host: "${get_sp('serviceNow.instance_name')}"
            - file_name: results.html
            - file_path: "C:\\Users\\Administrator\\Desktop\\RPA_Demo_Tests\\RPADemo_Test\\RPADemo_Test\\bin\\Release\\RunResults\\runresults.html"
            - sys_id: '${sys_id}'
            - table_name: incident
            - auth_type: Basic
            - username: "${get_sp('serviceNow.username')}"
            - password:
                value: "${get_sp('serviceNow.password')}"
                sensitive: true
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password: '${proxy_password}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: notify_slack
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      atach_file:
        x: 563
        y: 73
      incident_state_in_progress:
        x: 43
        y: 76
      incident_state_resolved:
        x: 390
        y: 73
      execute_leanFT_script:
        x: 213
        y: 75
      notify_slack:
        x: 740
        y: 73
        navigate:
          28fa1ca0-d3c7-ddca-919c-cdfb6a598680:
            targetId: 0c380b33-2d24-aa99-dbd0-896431a985b1
            port: SUCCESS
          3dc73a1e-0b37-bd4a-4af8-3253b31745fa:
            targetId: 0c380b33-2d24-aa99-dbd0-896431a985b1
            port: FAILURE
    results:
      SUCCESS:
        0c380b33-2d24-aa99-dbd0-896431a985b1:
          x: 910
          y: 77
