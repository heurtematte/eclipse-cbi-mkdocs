local k = import 'ksonnet-util/kausal.libsonnet';
local route = import '../okd/networking/route.libsonnet';
{
  local deployment = k.apps.v1.deployment,
  local statefulSet = k.apps.v1.statefulSet,
  local container = k.core.v1.container,
  local port = k.core.v1.containerPort,
  local service = k.core.v1.service,
  local servicePort = k.core.v1.servicePort,
  local secret = k.core.v1.secret,  
  local configMap = k.core.v1.configMap,
  local persistentVolumeClaim = k.core.v1.persistentVolumeClaim,
 
  getDomain(domain, environment)::
      if (environment == 'prod') then domain else 
      if (environment == 'staging') then 
        std.join(".", std.mapWithIndex(
          function(i, x) if i==0 then x +'-'+environment else x,
          std.split(domain, '.'))
        ) else 
      environment + '.' + domain
  , 

  withLabels(config, name)::
    {
      [config.organization + '/app']: name,
      [config.organization + '/env']: config.environment,
    },

  withHttpProbe(containerProbe, probe, containerPort)::
    containerProbe.withFailureThreshold(probe.failureThreshold) +
    containerProbe.withInitialDelaySeconds(probe.initialDelaySeconds) +
    containerProbe.withPeriodSeconds(probe.periodSeconds) +
    containerProbe.withTimeoutSeconds(probe.timeoutSeconds) +
    containerProbe.httpGet.withPath(probe.path) +
    containerProbe.httpGet.withPort(containerPort),

  // serviceFor create service for a given deployment.
  serviceFor(deployment, portExpose=80, ignored_labels=[], nameFormat='%(container)s-%(port)s')::
    
    local ports = [
      servicePort.newNamed(
        name=(nameFormat % { container: c.name, port: port.name }),
        port=portExpose,
        targetPort=port.name
      ) +
      if std.objectHas(port, 'protocol')
      then servicePort.withProtocol(port.protocol)
      else {}
      for c in deployment.spec.template.spec.containers
      for port in (c + container.withPortsMixin([])).ports
    ];
    local labels = {
      [x]: deployment.spec.template.metadata.labels[x]
      for x in std.objectFields(deployment.spec.template.metadata.labels)
      if std.count(ignored_labels, x) == 0
    };

    service.new(
      deployment.metadata.name,  // name
      labels,  // selector
      ports,
    ) +
    service.mixin.metadata.withLabels({ name: deployment.metadata.name }),

  serviceForContainer(container, portExpose=80, ignored_labels=[], nameFormat='%(container)s-%(port)s')::
    
    local ports = [
      servicePort.newNamed(
        name=(nameFormat % { container: container.name, port: port.name }),
        port=portExpose,
        targetPort=port.name
      ) +
      if std.objectHas(port, 'protocol')
      then servicePort.withProtocol(port.protocol)
      else {}
      for port in (container + container.withPortsMixin([])).ports
    ];
    local labels = {
      [x]: deployment.spec.template.metadata.labels[x]
      for x in std.objectFields(deployment.spec.template.metadata.labels)
      if std.count(ignored_labels, x) == 0
    };

    service.new(
      deployment.metadata.name,  // name
      labels,  // selector
      ports,
    ) +
    service.mixin.metadata.withLabels({ name: deployment.metadata.name }),

  configMap(name, namespace, labels, data):: 
    configMap.new(name, data) +
    configMap.metadata.withNamespace(namespace) +
    configMap.metadata.withLabelsMixin(labels),

  secretStringData(name, namespace, labels, stringData):: 
    secret.new(name, {empty: ''}) +
    secret.withStringData(stringData) +
    secret.metadata.withNamespace(namespace) +
    secret.metadata.withLabelsMixin(labels),


  secretData(name, namespace, labels, data):: 
    secret.new(name, data) +
    secret.metadata.withNamespace(namespace) +
    secret.metadata.withLabelsMixin(labels),

  defaultContainer(config)::container.new(config.name, config.image) +
        container.withImagePullPolicy(config.imagePullPolicy) + 
        container.withEnvMap(config.env) +
        container.withPorts(port.new(config.shortName + '-port', config.containerPort)) + 
        container.withResourcesLimits(config.resources.cpuLimit, config.resources.memoryLimit) + 
        container.withResourcesRequests(config.resources.cpuRequest, config.resources.memoryRequest) + 
        $.withHttpProbe(container.livenessProbe, config.probe.liveness, config.containerPort) + 
        $.withHttpProbe(container.readinessProbe, config.probe.readiness, config.containerPort),


  persistentVolumeClaim(config, namespace, labels, storageClassName="managed-nfs-storage-bambam"):: persistentVolumeClaim.new(
    config.name + '-pvc') +
    persistentVolumeClaim.metadata.withNamespace(namespace) +
    persistentVolumeClaim.metadata.withLabelsMixin(labels) +
    persistentVolumeClaim.spec.withAccessModes("ReadWriteOnce") +
    persistentVolumeClaim.spec.withStorageClassName(storageClassName) +
    persistentVolumeClaim.spec.resources.withRequests({"storage": "200Gi"}),

  deployment(config, namespace, labels, containers=self.defaultContainer(config)):: deployment.new(
      name=config.name, 
      replicas=config.replicas,
      podLabels=labels,
      containers=containers      
    ) + 
    deployment.metadata.withNamespace(namespace) +
    deployment.metadata.withLabelsMixin(labels),

  statefulSet(config, namespace, labels, containers=self.defaultContainer(config)):: statefulSet.new(
      name=config.name, 
      replicas=config.replicas,
      podLabels=labels,
      containers=containers      
    ) + 
    statefulSet.metadata.withNamespace(namespace) +
    statefulSet.metadata.withLabelsMixin(labels) + 
    statefulSet.spec.withServiceName(config.name),
  
  service(deployment, namespace, labels):: $.serviceFor(deployment, nameFormat='%(port)s-svc') +
    service.metadata.withNamespace(namespace) +
    service.metadata.withLabelsMixin(labels),

  serviceContainer(containers, namespace, labels):: 
    $.serviceForContainer(containers, nameFormat='%(container)s-%(port)s-svc') +
    service.metadata.withNamespace(namespace) +
    service.metadata.withLabelsMixin(labels),

  route(config, namespace, labels):: route.new(config.name) + 
    route.metadata.withNamespace(namespace) +
    route.metadata.withLabelsMixin(labels) + 
    route.spec.withHost(config.host) +
    route.spec.port.withTargetPort(config.containerPort) +
    route.spec.tls.withInsecureEdgeTerminationPolicy("Redirect") +
    route.spec.tls.withtermination("edge") +
    route.spec.to.withKind("Service") +
    route.spec.to.withName(config.name) +
    route.spec.to.withweight(100),
}
