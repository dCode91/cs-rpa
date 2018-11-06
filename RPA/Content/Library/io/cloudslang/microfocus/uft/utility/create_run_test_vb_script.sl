#   Copyright 2018, Micro Focus, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
########################################################################################################################
#!!
#! @description: This flow creates a VB script needed to run an UFT Scenario based on a
#!               default triggering template.
#!
#! @input host: The host where UFT scenarios are located.
#! @input username: The username for the WinRM connection.
#! @input password: The password for the WinRM connection.
#! @input port: The WinRM port of the provided host.
#!              Default for https: '5986'
#!              Default for http: '5985'
#! @input protocol: The WinRM protocol.
#! @input is_test_visible: Parameter to set if the UFT scenario actions should be visible in the UI or not.
#! @input test_path: The path to the UFT scenario.
#! @input test_results_path: The path where the UFT scenario will save its results.
#! @input key_value_delimiter: Delimiter between parameter's keys and values.
#! @input test_parameters: UFT scenario parameters from the UFT scenario. A list of name:value pairs separated by comma.
#!                         Eg. name1:value1,name2:value2
#! @input uft_workspace_path: The path where the OO will create needed scripts for UFT scenario execution.
#! @input quit_uft: Parameter to set if the UFT will quit after test execution.
#! @input auth_type: Type of authentication used to execute the request on the target server
#!                   Valid: 'basic', digest', 'ntlm', 'kerberos', 'anonymous' (no authentication).
#!                   Default: 'basic'
#!                   Optional
#! @input proxy_host: The proxy host.
#!                    Optional
#! @input proxy_port: The proxy port.
#!                    Default: '8080'
#!                    Optional
#! @input proxy_username: Proxy server user name.
#!                        Optional
#! @input proxy_password: Proxy server password associated with the proxy_username input value.
#!                        Optional
#! @input trust_all_roots: Specifies whether to enable weak security over SSL/TSL.
#!                         A certificate is trusted even if no trusted certification authority issued it.
#!                         Valid: 'true' or 'false'
#!                         Default: 'false'
#!                         Optional
#! @input x_509_hostname_verifier: Specifies the way the server hostname must match a domain name in the subject's
#!                                 Common Name (CN) or subjectAltName field of the X.509 certificate. The hostname
#!                                 verification system prevents communication with other hosts other than the ones you
#!                                 intended. This is done by checking that the hostname is in the subject alternative
#!                                 name extension of the certificate. This system is designed to ensure that, if an
#!                                 attacker(Man In The Middle) redirects traffic to his machine, the client will not
#!                                 accept the connection. If you set this input to "allow_all", this verification is
#!                                 ignored and you become vulnerable to security attacks. For the value
#!                                 "browser_compatible" the hostname verifier works the same way as Curl and Firefox.
#!                                 The hostname must match either the first CN, or any of the subject-alts. A wildcard
#!                                 can occur in the CN, and in any of the subject-alts. The only difference between
#!                                 "browser_compatible" and "strict" is that a wildcard (such as "*.foo.com") with
#!                                 "browser_compatible" matches all subdomains, including "a.b.foo.com".
#!                                 From the security perspective, to provide protection against possible
#!                                 Man-In-The-Middle attacks, we strongly recommend to use "strict" option.
#!                                 Valid: 'strict', 'browser_compatible', 'allow_all'.
#!                                 Default: 'strict'.
#!                                 Optional
#! @input trust_keystore: The pathname of the Java TrustStore file. This contains certificates from
#!                        other parties that you expect to communicate with, or from Certificate Authorities that
#!                        you trust to identify other parties.  If the protocol (specified by the 'url') is not
#!                        'https' or if trust_all_roots is 'true' this input is ignored.
#!                        Format: Java KeyStore (JKS)
#!                        Default value: 'JAVA_HOME/java/lib/security/cacerts'
#!                        Optional
#! @input trust_password: The password associated with the trust_keystore file. If trust_all_roots is false
#!                        and trust_keystore is empty, trust_password default will be supplied.
#!                        Default value: 'changeit'
#!                        Optional
#! @input operation_timeout: Defines the operation_timeout value in seconds to indicate that the clients expect a
#!                           response or a fault within the specified time.
#!                           Default: '60'
#! @input script: The run UFT scenario VB script template.
#! @input fileNumber: Used for development purposes
#!
#! @output script_name: Full path VB script
#! @output exception: Exception if there was an error when executing, empty otherwise.
#! @output stderr: An error message in case there was an error while running power shell
#! @output return_result: The scripts result.
#! @output return_code: '0' if success, '-1' otherwise.
#! @output script_exit_code: '0' if success, '-1' otherwise.
#! @output fileExists: file exist.
#!
#! @result FAILURE: The operation could not be executed.
#! @result SUCCESS: The operation executed successfully.
#!!#
########################################################################################################################

namespace: io.cloudslang.microfocus.uft.utility
imports:
  strings: io.cloudslang.base.strings
  ps: io.cloudslang.base.powershell
  math: io.cloudslang.base.math
  prop: io.cloudslang.microfocus.uft
flow:
  name: create_run_test_vb_script
  inputs:
    - host
    - username:
        required: false
    - password:
        required: false
        sensitive: true
    - port:
        required: false
    - protocol:
        required: false
    - is_test_visible: 'True'
    - test_path
    - test_results_path
    - key_value_delimiter: ':'
    - test_parameters
    - uft_workspace_path
    - quit_uft: 'True'
    - auth_type:
        default: basic
        required: false
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
    - trust_all_roots:
        default: 'false'
        required: false
    - x_509_hostname_verifier:
        default: strict
        required: false
    - trust_keystore:
        default: ''
        required: false
    - trust_password:
        default: changeit
        required: false
        sensitive: true
    - operation_timeout:
        default: '60'
        required: false
    - script: "${get_sp('io.cloudslang.microfocus.uft.run_robot_script_template')}"
    - fileNumber:
        default: '0'
        private: true
  workflow:
    - add_test_path:
        do:
          strings.search_and_replace:
            - origin_string: '${script}'
            - text_to_replace: '<test_path>'
            - replace_with: '${test_path}'
        publish:
          - script: '${replaced_string}'
        navigate:
          - SUCCESS: add_test_results_path
          - FAILURE: on_failure
    - create_vb_script:
        do:
          ps.powershell_script:
            - host
            - port
            - protocol
            - username
            - password:
                value: '${password}'
                sensitive: true
            - auth_type
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password:
                value: '${trust_password}'
                sensitive: true
            - trust_all_roots
            - x_509_hostname_verifier
            - trust_keystore
            - trust_password:
                value: '${trust_password}'
                sensitive: true
            - operation_timeout
            - script: "${'Set-Content -Path \"' + uft_workspace_path.rstrip(\"\\\\\") + \"\\\\\" + test_path.split(\"\\\\\")[-1] + '_' + fileNumber + '.vbs\" -Value \"'+ script +'\" -Encoding ASCII'}"
        publish:
          - exception
          - return_code
          - return_result
          - script_exit_code
          - stderr
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - add_test_results_path:
        do:
          strings.search_and_replace:
            - origin_string: '${script}'
            - text_to_replace: '<test_results_path>'
            - replace_with: '${test_results_path}'
        publish:
          - script: '${replaced_string}'
        navigate:
          - SUCCESS: is_test_visible
          - FAILURE: on_failure
    - add_parameter:
        loop:
          for: "parameter in test_parameters.replace(\"\\,\",\"§\")"
          do:
            strings.append:
              - origin_string: "${get('text', '')}"
              - text: "${'qtParams.Item(`\"' + parameter.split(key_value_delimiter)[0] + '`\").Value = `\"' + parameter.split(key_value_delimiter)[1] +'`\"`r`n'}"
          break: []
          publish:
            - text: '${new_string.replace("§",",")}'
        navigate:
          - SUCCESS: add_parameters
    - add_parameters:
        do:
          strings.search_and_replace:
            - origin_string: '${script}'
            - text_to_replace: '<params>'
            - replace_with: '${text}'
        publish:
          - script: '${replaced_string}'
        navigate:
          - SUCCESS: create_folder_structure
          - FAILURE: on_failure
    - is_test_visible:
        do:
          strings.search_and_replace:
            - origin_string: '${script}'
            - text_to_replace: '<visible_param>'
            - replace_with: '${is_test_visible}'
        publish:
          - script: '${replaced_string}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: is_quit_uft
    - create_folder_structure:
        do:
          ps.powershell_script:
            - host
            - port
            - protocol
            - username
            - password:
                value: '${password}'
                sensitive: true
            - auth_type
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - trust_all_roots
            - x_509_hostname_verifier
            - trust_keystore
            - trust_password:
                value: '${trust_password}'
                sensitive: true
            - operation_timeout
            - script: "${'New-item \"' + uft_workspace_path.rstrip(\"\\\\\") + \"\\\\\" + '\" -ItemType Directory -force'}"
        publish:
          - exception
          - stderr
          - return_result
          - return_code
          - script_exit_code
          - scriptName: output_0
        navigate:
          - SUCCESS: check_if_filename_exists
          - FAILURE: on_failure
    - check_if_filename_exists:
        do:
          ps.powershell_script:
            - host
            - port
            - protocol
            - username
            - password:
                value: '${password}'
                sensitive: true
            - auth_type
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - trust_all_roots
            - x_509_hostname_verifier
            - trust_keystore
            - trust_password:
                value: '${trust_password}'
                sensitive: true
            - operation_timeout
            - script: "${'Test-Path \"' + uft_workspace_path.rstrip(\"\\\\\") + \"\\\\\" + test_path.split(\"\\\\\")[-1] + '_' + fileNumber +  '.vbs\"'}"
        publish:
          - exception
          - stderr
          - return_result
          - return_code
          - script_exit_code
          - fileExists: '${return_result}'
        navigate:
          - SUCCESS: string_equals
          - FAILURE: on_failure
    - string_equals:
        do:
          strings.string_equals:
            - first_string: '${fileExists}'
            - second_string: 'True'
        navigate:
          - SUCCESS: add_numbers
          - FAILURE: create_vb_script
    - add_numbers:
        do:
          math.add_numbers:
            - value1: '${fileNumber}'
            - value2: '1'
        publish:
          - fileNumber: '${result}'
        navigate:
          - SUCCESS: check_if_filename_exists
          - FAILURE: on_failure
    - delete_quit_uft_line:
        do:
          io.cloudslang.base.strings.search_and_replace:
            - origin_string: '${script}'
            - text_to_replace: qtApp.Quit
            - replace_with: ''
        publish:
          - script: '${replaced_string}'
        navigate:
          - SUCCESS: add_parameter
          - FAILURE: on_failure
    - is_quit_uft:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: '${quit_uft}'
        navigate:
          - 'TRUE': add_parameter
          - 'FALSE': delete_quit_uft_line
  outputs:
    - script_name: "${uft_workspace_path.rstrip(\"\\\\\") + \"\\\\\" + test_path.split(\"\\\\\")[-1] + '_' + fileNumber + '.vbs'}"
    - exception
    - stderr
    - return_result
    - return_code
    - script_exit_code
    - fileExists
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      create_folder_structure:
        x: 1108
        y: 56
      add_parameters:
        x: 893
        y: 53
      is_quit_uft:
        x: 571
        y: 49
      check_if_filename_exists:
        x: 1101
        y: 300
      add_parameter:
        x: 675
        y: 56
      add_numbers:
        x: 908
        y: 506
      delete_quit_uft_line:
        x: 544
        y: 221
      string_equals:
        x: 936
        y: 278
      add_test_path:
        x: 40
        y: 58
      is_test_visible:
        x: 371
        y: 59
      create_vb_script:
        x: 531
        y: 346
        navigate:
          c3db07a5-d125-3877-5aba-a4077607d789:
            targetId: 09dd53a1-80a5-775c-ecf2-2930999b2b46
            port: SUCCESS
      add_test_results_path:
        x: 206
        y: 59
    results:
      SUCCESS:
        09dd53a1-80a5-775c-ecf2-2930999b2b46:
          x: 526
          y: 515
