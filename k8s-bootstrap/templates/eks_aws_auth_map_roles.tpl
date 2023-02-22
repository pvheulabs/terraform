- rolearn: arn:aws:iam::${aws_account_id}:role/${eks_cluster_name}-worker-iamrole
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
%{if length(sso_admin_roles) > 0 }
%{ for sso in sso_admin_roles ~}
- rolearn: arn:aws:iam::${aws_account_id}:role/${sso}
  username: admin
  groups:
    - system:masters
%{ endfor ~}
%{ endif }
%{if length(deployment_roles) > 0 }
%{ for deprole in deployment_roles ~}
- rolearn: arn:aws:iam::${aws_account_id}:role/${deprole}
  username: admin
  groups:
    - system:masters
%{ endfor ~}
%{ endif }
