namespace: SNOW
flow:
  name: update_incident
  inputs:
    - host
    - api_version:
        required: false
    - sys_id
    - auth_type:
        required: false
    - username:
        required: false
        sensitive: false
    - password:
        required: false
        sensitive: true
    - incident_state:
        required: false
    - request_body
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
  workflow:
    - http_client_put:
        do:
          io.cloudslang.base.http.http_client_put:
            - url: "${host + '/api/now' + api_version + '/table/incident/' + sys_id}"
            - auth_type: '${auth_type}'
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
            - body: '${request_body}'
            - content_type: application/json
        publish:
          - return_result
          - status_code
        navigate:
          - SUCCESS: is_200
          - FAILURE: on_failure
    - is_200:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${status_code}'
            - second_string: '200'
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      http_client_put:
        x: 40
        y: 109
      is_200:
        x: 317
        y: 87
        navigate:
          8e547d07-8998-77ba-6138-879271f38b6b:
            targetId: 3a2627b2-edfb-f2c3-bcbd-af7cdd6d2918
            port: SUCCESS
    results:
      SUCCESS:
        3a2627b2-edfb-f2c3-bcbd-af7cdd6d2918:
          x: 530
          y: 96
