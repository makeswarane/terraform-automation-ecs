# OIDC Role creation for GitHub Actions (example) 

Replace <ACCOUNT_ID> and <REPO>.

trust.json:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<OWNER>/<REPO>:*"
        }
      }
    }
  ]
}

aws iam create-role --role-name GitHubActionsTerraformRole --assume-role-policy-document file://trust.json
aws iam attach-role-policy --role-name GitHubActionsTerraformRole --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
# **Replace AdministratorAccess with least-privilege policy in production**.
