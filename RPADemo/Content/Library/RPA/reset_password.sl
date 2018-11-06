namespace: RPA
flow:
  name: reset_password
  inputs:
    - portal_url: 'http://advantageonlineshopping.com/#/'
    - portal_user: dani_crisan
    - old_password:
        sensitive: true
    - new_password:
        sensitive: true
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
  workflow:
    - trigger_robot:
        do:
          uft.trigger_robot:
            - host: "${get_sp('leanFT.host')}"
            - port: '5985'
            - protocol: http
            - username: "${get_sp('leanFT.user')}"
            - password: "${get_sp('leanFT.password')}"
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - is_robot_visible: 'True'
            - robot_path: "C:\\UFT\\ChangePassword_OO"
            - robot_results_path: "C:\\UFT\\ChangePassword_OO\\Results"
            - robot_parameters: "${'Password:'+ old_password +',NewPassword:' + new_password}"
            - rpa_workspace_path: "C:\\RPA"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: notify_slack
    - notify_slack:
        do:
          Slack.post_message:
            - message: Your password has been reset. You can try login using the new password.
            - token:
                value: "${get_sp('chatops.token')}"
                sensitive: true
            - channel: "${get_sp('chatops.channel')}"
        navigate:
          - FAILURE: SUCCESS
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      trigger_robot:
        x: 207
        y: 77
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
