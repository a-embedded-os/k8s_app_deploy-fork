# Continuous Integration and Deployment with P9 Managed Kubernetes

As the topic of CICD has a long [history](https://martinfowler.com/tags/continuous%20delivery.html)
we will not go into too much depth on it; you can read further on your own. However, we will hi-light
some fundamental principles as they pertain to your own CICD pipelines and Kubernetes. Please take a
few moments to read these and keep them in mind as you design your own pipelines for your organization.

## CICD Design Principles

- Any change to the application code in the SCM repository should trigger a new image build.
- The change to the application code could ideally trigger an automated bump of the application version.
- Tag the SCM repository every time the application version changes.
- Following an application image build, tag the image with `latest` and the new repo tag.
- Always deploy the latest image into a Test Kubernetes environment.
- Keep the application's Kubernetes manifests alongside the application code in the same SCM repo.
- Any change to these Kubernetes manifests should not in and of themselves trigger a new image build.
- A change to the Kubernetes manifests should always trigger a new deployment into the Test environment.
- Whilst the application code is versioned via SCM repo tags, the Kubernetes manifests could have their
own change tracking via SCM commit SHA recorded as an annotation in each resource.
- Following validation of the Test environment, there should be a pipeline to allow for selective
releases of an arbitrary image version into a Production environment. Ideally, the control of which
version should be stored in SCM for visibility.
