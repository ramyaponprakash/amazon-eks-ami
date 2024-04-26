## ADEX EKS infra and commons

---

### CICD and common job guides

The `./cicd` folder contains GitLab pipelines, scripts and common reusable jobs.
More details are available in the [`./cicd/README.md`](./cicd/README.md) file.

---

### App EKS vs Solace EKS

The `App EKS` files are located in the [`sense`](./sense) folder. 
This setup is intended for provisioning and chart installations in the `dev` environment App EKS.
We can refactor both the folder and `App EKS` to utilize the Solace-based common implementations.

More details about App EKS: [README.md](./sense/README.md).


In contrast, `Solace EKS` environments will utilize the [`modules`](./modules) 
and [`environments`](./environments) directories in the project root.

---

### How to upgrade Solace EKS cluster

1. Run `Image-Builder` pipeline to create the targeted version AMI.
2. Upgrade the control plane version via AWS EKS web console. 
3. Run `Solace-EKS-terraform` pipeline.
4. Apply jobs in sequence: `eks` -> `eks-solace`. This will generate a new template version.
5. Verify which nodegroup is hosting `StandBy` and `Active` pod.
6. Upgrade node group via AWS EKS web console, in sequence: `default` -> `monitoring` -> `StandBy role broker` -> `Active role broker`. 
7. Upgrade add-ons via AWS EKS web console.
8. Upgrade charts following the new version supports.

Related page: 
- [Scheduled Maintenance](https://confluence.ship.gov.sg/display/SDX/Scheduled+Maintenance)
- [Procedure for Special Needs Instance Types](https://confluence.ship.gov.sg/display/SDX/Procedure+for+Special+Needs+Instance+Types)
