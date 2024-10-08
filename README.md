# terraform-eks

This project is a demonstration of a EKS cluter that is deployed via terraform and managed via ArgoCD. This project follows a relatively simple structure, there are two main folders, components, and live.

## Components

The components directory contains the various parts of this project organized by business logic and deploy order. These directories contain the actual terraform code, each component contains a main.tf, variables.tf, and some have an output.tf. These components are linked together via terragrunt to manage the deployments themselves to deal with inputs/outputs.

## Live 
The live directory is structured as such `live\environment\<environment-name>` in this demonstration that environment is `test`. In a real business deployment I would add the various environments (e.g. QA, Prod, Dev), within this directory. Within the `<environment-name>` directory there are directories for each component that define key parts of each component.

I chose to use terragrunt in this project to do two specific things, keep our terraform code DRY, and make our infrastructure defined in smaller pieces. This makes state management more straightforward, makes each part more easily iterable, allows smaller changes to infrastructure without full state refreshes or changes.

Each components `terragrunt.hcl` uses the root level `terragrunt.hcl` to define local variables, remote state configuration, and provider information. This allows that to be easily generated and not repeated for each component. There is also a `kubernetes.hcl` file, which overrides the provider information for components that need access to the Kubernetes control plane.

## How to deploy this 
This project was designed to be deployed in a mostly empty aws account, the instructions below will assume you're using the pre-defined test environment. You will also need a domain name hosted in Route53. First we'll need to set the variables to be shared between the components.

Prerequesites
- terraform
- terragrunt
- kubectl
- aws profile and account configured

1. Edit the root level `terragrunt.hcl`, change the region, tld, and, email as required.
2. Ensure you are in the root level of this project, and run `make all`

This will begin the deployment process.

Each component is deployed in order by this command, you can also choose to deploy them in the order described in the `Makefile` with `make <component name>`. 

## Caveats
There were a few compromises made in this project since it's just a demo 
- The state for the bootstrap component is stored locally
    - To me this was acceptable for this as it's only 4 infrastructure pieces, it's immutable and won't change
- ArgoCD admin credentials use the autogenerated admin account, this is passed as a "secure" variable within terraform
    - ArgoCD reccomends only using this account for setup purposes, since that is what is happening here I found this compromise acceptable. In a real produciton workflow IAM would be handled at the cluster level and the ArgoCD provider would have it's own user and generated token for new IaC usage.
- Dependencies aren't always avaliable right away 
    - During development of this project I found that sometimes due to the way terraform applies changes that the cluster didn't always have the required kubernetes objects ready when applying the ingress manifests. This is resolved by simply re-running the failed steps when they are ready.
- Exposing the ArgoCD login directly to the internet
    - yeah don't do this, again, it's a demo, in produciton put this behind a vpn
    
