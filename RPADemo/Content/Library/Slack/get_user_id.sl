namespace: Slack
flow:
  name: get_user_id
  workflow:
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: 'https://slack.com/api/users.list?token=slack_token&pretty=1'
            - proxy_host: web-proxy.eu.hpecorp.net
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      http_client_get:
        x: 79
        y: 94
        navigate:
          760f9d89-018e-f745-1f4e-08bbc45e81c5:
            targetId: 1c312f48-8ae6-7cd5-8048-e0ca424aa002
            port: SUCCESS
    results:
      SUCCESS:
        1c312f48-8ae6-7cd5-8048-e0ca424aa002:
          x: 312
          y: 53
