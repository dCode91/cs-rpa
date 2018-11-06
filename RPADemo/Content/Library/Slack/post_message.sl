namespace: Slack
flow:
  name: post_message
  inputs:
    - message
    - token:
        sensitive: true
    - channel
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
        sensitive: true
  workflow:
    - http_client_post:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: 'https://slack.com/api/chat.postMessage'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - headers: "${'Authorization:Bearer ' + token}"
            - body: "${'{ \\'text\\':\\''+ message + '\\', \\'channel\\':\\'' + channel + '\\',  \\'as_user\\':true }'}"
            - content_type: application/json
        publish:
          - return_result
        navigate:
          - SUCCESS: json_path_query
          - FAILURE: on_failure
    - is_true:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${isOk}'
        navigate:
          - 'TRUE': SUCCESS
          - 'FALSE': FAILURE
    - json_path_query:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${return_result}'
            - json_path: $.ok
        publish:
          - isOk: '${return_result}'
        navigate:
          - SUCCESS: is_true
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      http_client_post:
        x: 86
        y: 104
      is_true:
        x: 589
        y: 87
        navigate:
          9e5eed67-bc83-6abf-348b-77d86a60deed:
            targetId: f58178b6-474d-a5b1-7401-d6267ae9f330
            port: 'TRUE'
          6dd3879b-348d-45df-68fa-95279efabec3:
            targetId: 9c4c2663-8474-498a-4622-5ebc1117b593
            port: 'FALSE'
      json_path_query:
        x: 296
        y: 105
    results:
      FAILURE:
        9c4c2663-8474-498a-4622-5ebc1117b593:
          x: 562
          y: 298
      SUCCESS:
        f58178b6-474d-a5b1-7401-d6267ae9f330:
          x: 793
          y: 99
