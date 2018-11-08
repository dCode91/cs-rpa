namespace: RPA
flow:
  name: TestFlow
  workflow:
    - run_test:
        do:
          io.cloudslang.microfocus.uft.run_test:
            - host: 
            - username: administrator
            - password:
                value: ''
                sensitive: true
            - port: '5985'
            - protocol: http
            - is_test_visible: 'true'
            - test_path: "C:\\UFT\\ChangePassword_OO"
            - test_results_path: "C:\\RPA"
            - uft_workspace_path: "C:\\RPA"
            - key_value_delimiter: ;
            - test_parameters: "Usename;dani_\\,crisan,Password;Pass123,NewPassword;Pass321"
            - quit_uft: 'false'
            - proxy_host: web-proxy.eu.softwaregrp.net
            - proxy_port: '8080'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      run_test:
        x: 43
        y: 77
        navigate:
          db2e0bde-1fd2-74bf-34cb-aa7313236733:
            targetId: 298fac33-cb69-8ff2-ad6a-d727cb9a999c
            port: SUCCESS
            vertices: []
    results:
      SUCCESS:
        298fac33-cb69-8ff2-ad6a-d727cb9a999c:
          x: 321
          y: 81
