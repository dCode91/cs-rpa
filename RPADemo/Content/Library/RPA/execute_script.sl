namespace: RPA
flow:
  name: execute_script
  inputs:
    - host
    - protocol
    - port
    - username
    - password
    - script
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
  workflow:
    - powershell_script:
        do:
          io.cloudslang.base.powershell.powershell_script:
            - host: '${host}'
            - port: '${port}'
            - protocol: '${protocol}'
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - script: '${script}'
        publish:
          - exception
          - return_code
          - stderr
          - script_exit_code
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      powershell_script:
        x: 45
        y: 82
        navigate:
          0af62a15-abc5-81bf-9147-eac5815a7ac4:
            targetId: 023c90fc-05ed-adf3-eb3c-da02c1f4333a
            port: SUCCESS
    results:
      SUCCESS:
        023c90fc-05ed-adf3-eb3c-da02c1f4333a:
          x: 335
          y: 85
