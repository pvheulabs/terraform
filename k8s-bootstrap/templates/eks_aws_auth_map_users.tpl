%{if length(eks_admin_users) > 0 }
%{ for user in eks_admin_users ~}
- userarn:  arn:aws:iam::${aws_account_id}:user/${user}
  username: admin
  groups:
    - system:masters
%{ endfor ~}
%{ endif }
