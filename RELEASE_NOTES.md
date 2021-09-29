 * Adds a check for acceptable client certificate CAs (``` (--require-client-cert [list])```)
 * Supporting certificate expiration after 2038-01-19 on 32 bit systems
 * Adds an option (```--ignore-connection-problem```) to set a custom state in case of connection failures
 * Adds two options to selectively disable proxy setting for cURL and s_client (```--no-proxy-curl``` and ```--no-proxy-s_client```)