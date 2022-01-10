# Jenkins deployment on Platform9 Managed Kubernetes

Jenkins is a well known, widely adopted Continuous Integration platform in enterprises.
In this pipeline, Jenkins manages a `Deployment` to one of your Platform9 Managed Kubernetes clusters.

Here we are going to deploy Jenkins on top of platform9 managed kubernetes. The Jenkins docker image provided here has Openjdk8, Maven, Go and NodeJS preinstalled with commonly used plugins. It can be further customized once Jenkins is up and running. The resulting application `Deployment` has a load balancer for external access to the service.
