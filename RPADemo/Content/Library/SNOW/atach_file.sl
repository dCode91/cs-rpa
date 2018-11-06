namespace: SNOW
flow:
  name: atach_file
  inputs:
    - host
    - api_version:
        default: /v1
        required: false
    - file_name
    - file_path
    - sys_id
    - table_name
    - auth_type:
        required: false
    - username:
        required: false
        sensitive: false
    - password:
        required: false
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
    - http_client_action:
        do:
          io.cloudslang.base.http.http_client_action:
            - url: "${host + '/api/now' + api_version + '/attachment/file?table_name=' + table_name + '&table_sys_id=' + sys_id + '&file_name=' + file_name}"
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
            - source_file: '${file_path}'
            - content_type: text/html
            - method: POST
        publish:
          - status_code
          - return_result
        navigate:
          - SUCCESS: is_201
          - FAILURE: on_failure
    - is_201:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${status_code}'
            - second_string: '201'
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - status_code: '${status_code}'
    - return_result: '${return_result}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      http_client_action:
        x: 49
        y: 110
        navigate:
          3bc7f9b4-56c3-3f57-6344-6ea1034f5762:
            vertices:
              - x: 263
                y: 144
            targetId: is_201
            port: SUCCESS
      is_201:
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
