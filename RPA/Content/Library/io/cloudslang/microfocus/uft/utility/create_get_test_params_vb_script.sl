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
#! @description: This flow creates a VB script needed to run an UFT Scenario based on a deafult triggering
#!               template. An UFT scenario is equivaleant to an RPA robot.
#! @input host: The host where UFT scenarios are located.
#! @input port: The WinRM port of the provided host.
#!                    Default: https: '5986' http: '5985'
#! @input protocol: The WinRM protocol.
#! @input username: The username for the WinRM connection.
#! @input password: The password for the WinRM connection.
#! @input test_path: The path to the UFT scenario.
#! @input uft_workspace_path: The path where the OO will create needed scripts for UFT scenario execution.
#! @input script: The run UFT scenario VB script template.
#! @input fileNumber: Used for development purposes.
#! @input auth_type:Type of authentication used to execute the request on the target server
#!                  Valid: 'basic', digest', 'ntlm', 'kerberos', 'anonymous' (no authentication).
#!                    Default: 'basic'
#!                    Optional
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
#!                       'https' or if trust_all_roots is 'true' this input is ignored.
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
#!
#! @output script_name: Full path for VB script.
#! @output exception: Exception if there was an error when executing, empty otherwise.
#! @output return_code: '0' if success, '-1' otherwise.
#! @output return_result: The scripts result.
#! @output stderr: An error message in case there was an error while running power shell
#! @output script_exit_code: '0' if success, '-1' otherwise.
#!
#! @result SUCCESS: The operation executed successfully.
#! @result FAILURE: The operation could not be executed.
#!
#!!#
########################################################################################################################

namespace: io.cloudslang.microfocus.uft.utility

imports:
  strings: io.cloudslang.base.strings
  ps: io.cloudslang.base.powershell
  math: io.cloudslang.base.math
  prop: io.cloudslang.microfocus.uft

flow:
  name: create_get_test_params_vb_script
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
    - test_path
    - uft_workspace_path
    -  auth_type:
        default: 'basic'
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
        default: 'strict'
        required: false
    - trust_keystore:
        default: ''
        required: false
    - trust_password:
        default: 'changeit'
        required: false
        sensitive: true
    - operation_timeout:
        default: '60'
        required: false
    - script: ${get_sp('io.cloudslang.microfocus.uft.get_robot_params_script_template')}

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
          - SUCCESS: create_folder_structure
          - FAILURE: on_failure
    - create_vb_script:
        do:
          ps.powershell_script:
            - host: '${host}'
            - port: '${port}'
            - protocol: '${protocol}'
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
            - auth_type: '${auth_type}'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - trust_keystore: '${trust_keystore}'
            - trust_password:
                value: '${trust_password}'
                sensitive: true
            - operation_timeout: '${operation_timeout}'
            - script: "${'Set-Content -Path \"' + uft_workspace_path.rstrip(\"\\\\\") + \"\\\\\" + test_path.split(\"\\\\\")[-1] +  '_get_params_' + fileNumber + '.vbs \" -Value \"'+ script +'\" -Encoding ASCII'}"
        publish:
          - exception
          - return_code
          - return_result
          - stderr
          - script_exit_code
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - create_folder_structure:
        do:
          ps.powershell_script:
            - host: '${host}'
            - port: '${port}'
            - protocol: '${protocol}'
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
            - auth_type: '${auth_type}'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - trust_keystore: '${trust_keystore}'
            - trust_password:
                value: '${trust_password}'
                sensitive: true
            - operation_timeout: '${operation_timeout}'
            - script: "${'New-item \"' + uft_workspace_path.rstrip(\"\\\\\") + \"\\\\\" + '\" -ItemType Directory -force'}"
        publish:
          - exception
          - return_code
          - return_result
          - stderr
          - script_exit_code
        navigate:
          - SUCCESS: check_if_filename_exists
          - FAILURE: on_failure
    - check_if_filename_exists:
        do:
          ps.powershell_script:
            - host: '${host}'
            - port: '${port}'
            - protocol: '${protocol}'
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
            - auth_type: '${auth_type}'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - trust_keystore: '${trust_keystore}'
            - trust_password:
                value: '${trust_password}'
                sensitive: true
            - operation_timeout: '${operation_timeout}'
            - script: "${'Test-Path \"' + uft_workspace_path.rstrip(\"\\\\\") + \"\\\\\" + test_path.split(\"\\\\\")[-1] +  '_get_params_' + fileNumber + '.vbs\"'}"
        publish:
          - exception
          - return_code
          - return_result
          - stderr
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

  outputs:
    - script_name: "${uft_workspace_path.rstrip(\"\\\\\") + \"\\\\\" + test_path.split(\"\\\\\")[-1] +  '_get_params_' + fileNumber + '.vbs'}"
    - exception
    - return_code
    - return_result
    - stderr
    - script_exit_code
  results:
    - FAILURE
    - SUCCESS

extensions:
  graph:
    steps:
      add_test_path:
        x: 39
        y: 74
      create_folder_structure:
        x: 287
        y: 72
      check_if_filename_exists:
        x: 535
        y: 68
      add_numbers:
        x: 840
        y: 339
      string_equals:
        x: 868
        y: 48
      create_vb_script:
        x: 1090
        y: 60
        navigate:
          29bfc0d9-87d5-9e70-6c5d-d18b940010b9:
            targetId: 7afe3cef-e39b-ea59-167d-8e1ee27a6efc
            port: SUCCESS
    results:
      SUCCESS:
        7afe3cef-e39b-ea59-167d-8e1ee27a6efc:
          x: 1315
          y: 68
