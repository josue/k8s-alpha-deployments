### About Kubernetes Alpha Deployments

Using Helm with Ambassador, you can generate routes for alpha deployments that are routed to your own CNAME (ie: `*.alpha`)

Hence, developers can deploy their alpha build (app) to a k8s namespace (`alpha`) and then use this build to test their app before merging to the mainline repo.

On helm release deploy, this would generate a dynamic alpha URL which uses the Values `app` + `commit` hash to create the deployment publicly available host.

Example Alpha URL: `http://api-e78587c397.alpha.domain.com` 

### Installation & Deployment Steps:

1. Instead [Ambassador](https://www.getambassador.io/user-guide/helm), like:
```bash
helm upgrade --install --wait my-ambassador stable/ambassador
```

2. Extract the the Ambassador k8s service `External IP`:
```bash
kubectl get svc -o wide ambassador
````
_expected output:_
```
NAME        TYPE          CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE   SELECTOR
ambassador  LoadBalancer  10.x.x.x     35.x.x.x      80:31131/TCP   17m   service=ambassador
```

3. Create the following DNS entry with the Ambassador `External IP`:

| Type | Name | Value |
| ---- | ---- | ----- |
| CNAME | *.alpha | 35.x.x.x |

4. Modify the Values.yaml file with your repo's `app` name and the repo's latest `commit`:

_Example Values.yaml required:_
```yaml
app: api
commit: e78587c397e259747e6bc52e39aff1c8887fb279
```

5. On your CI/CD deployments (ie: Jenkins, etc) create a Helm release for your application:

```bash
helm upgrade --debug --install --wait alpha-app-1 ./alpha
```

_Example template populated during release:_

```yaml
---
# Source: alpha/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  app: api
  name: api-e78587c397
  namespace: alpha
  alpha.deploy: true
  annotations:
    getambassador.io/config: |
      ---
      apiVersion: ambassador/v1
      kind: Mapping
      name: api-e78587c397
      host: api-e78587c397.alpha.domain.com
      prefix: /
      service: api-e78587c397.alpha:80
spec:
  selector:
    app: api-e78587c397
  ports:
  - protocol: TCP
    port: 80
---
# Source: alpha/templates/deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  app: api
  name: api-e78587c397
  namespace: alpha
  alpha.deploy: true
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: api-e78587c397
    spec:
      containers:
      - name: httpd
        image: "httpd"
        ports:
        - containerPort: 80
```

The above will output a message like the following with the alpha URL where the application has deployed:

> Alpha URL: http://api-e78587c397.alpha.domain.com

----
Note: You can create a weekly cronjob to delete all alpha deployments after inactivity.

To delete the existing Helm release:
```bash
helm delete alpha-app-1
```
