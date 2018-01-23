# openshift-vsftp

This Docker image implements a vsftpd server, with the following features:

 * Red Hat RHEL 7 base image
 * vsftpd 3.0.2
 * Virtual users
 * Passive mode
 * Logging to a file or STDOUT.

Use cases
----

0) Build image
```bash
 oc new-build https://github.com/rbaumgar/openshift-vsftp
``` 

1) Run image temporary testing purposes:

```bash
  docker run --rm openshift-vsftp
```

2) Create a container in active mode using the default user account, with a binded data directory:

```bash
docker run -d -p 21:21 -v /my/data/directory:/home/vsftpd \
-e FTP_USER=user -e FTP_PASS=pass1234 \
-e PASV_ADDRESS=127.0.0.1 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
--name vsftpd openshift-vsftp
docker logs vsftpd
```
3) create external IP adress, if not already done
External IPs assigned to services of type LoadBalancer will always be in the range of ingressIPNetworkCIDR. If ingressIPNetworkCIDR is changed such that the assigned external IPs are no longer in range, the affected services will be assigned new external IPs compatible with the new range.

Sample /etc/origin/master/master-config.yaml

``` 
   ...
   networkConfig:
     ingressIPNetworkCIDR: 172.29.0.0/16
   ...
``` 
You need to restart the master if you change the configuration with: systemctl restart atomic.openshift.master
On Minishift you can do this by
```
minishift openshift config set --patch '{"networkConfig": {"ingressIPNetworkCIDR": ["172.29.0.0/16"] }}'
```

Configuring an Ingress IP for a Service
----
``` 
cat <<EOF | oc create -f
apiVersion: v1
kind: Service
metadata:
  name: vsftp
spec:
  loadBalancerIP: 172.29.0.1
  ports:
  - name: 20-tcp
    port: 20
    protocol: TCP
    targetPort: 20
  - name: 21-tcp
    port: 21
    protocol: TCP
    targetPort: 21
  selector:
    deploymentconfig: openshift-vsftp
  type: LoadBalancer
EOF

oc get svc vsftp
NAME              CLUSTER-IP     EXTERNAL-IP             PORT(S)                     AGE
vsftp             172.30.107.7   172.29.0.1,172.29.0.1   20:30167/TCP,21:30525/TCP   4d
```

Routing the Ingress CIDR for Development or Testing
----
Add a static route directing traffic for the ingress CIDR to a node in the cluster. For example:

``` 
# route add -net 172.29.0.0/16 gw 10.66.140.17 eth0
``` 

In the example above, 172.29.0.0/16 is the ingressIPNetworkCIDR, and 10.66.140.17 is the node IP.


Environment variables
----

This image uses environment variables to allow the configuration of some parameteres at run time:

* Variable name: `FTP_USER`
* Default value: admin
* Accepted values: Any string. Avoid whitespaces and special chars.
* Description: Username for the default FTP account. If you don't specify it through the `FTP_USER` environment variable at run time, `admin` will be used by default.

----

* Variable name: `FTP_PASS`
* Default value: Random string.
* Accepted values: Any string.
* Description: If you don't specify a password for the default FTP account through `FTP_PASS`, a 16 characters random string will be automatically generated. You can obtain this value through the [container logs](https://docs.docker.com/reference/commandline/logs/).

----

* Variable name: `PASV_ADDRESS`
* Default value: Docker host IP.
* Accepted values: Any IPv4 address.
* Description: If you don't specify an IP address to be used in passive mode, the routed IP address of the Docker host will be used. Bear in mind that this could be a local address.

----

* Variable name: `PASV_MIN_PORT`
* Default value: 21100.
* Accepted values: Any valid port number.
* Description: This will be used as the lower bound of the passive mode port range. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `PASV_MAX_PORT`
* Default value: 21110.
* Accepted values: Any valid port number.
* Description: This will be used as the upper bound of the passive mode port range. It will take longer to start a container with a high number of published ports.

----

* Variable name: LOG_STDOUT
* Default value: Empty string.
* Accepted values: Any string to enable, empty string or not defined to disable.
* Description: Output vsftpd log through STDOUT, so that it can be accessed through the [container logs](https://docs.docker.com/reference/commandline/logs/).

----

Exposed ports and volumes
----

The image exposes ports `20` and `21`. Also, exports two volumes: `/home/vsftpd`, which contains users home directories, and `/var/log/vsftpd`, used to store logs.

