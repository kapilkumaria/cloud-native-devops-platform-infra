# ============================================================
# Amazon EBS CSI Driver for Project 1 - EKS
# ============================================================
#
# Purpose:
# Enable EKS workloads to provision EBS-backed PersistentVolumes.
#
# Authentication:
# EKS Pod Identity
#
# Storage provisioner:
# ebs.csi.aws.com
#
# ============================================================


# ------------------------------------------------------------
# 1. EKS Pod Identity Agent
# ------------------------------------------------------------

resource "aws_eks_addon" "pod_identity_agent" {

  cluster_name = aws_eks_cluster.eks.name

  addon_name = "eks-pod-identity-agent"

  depends_on = [
    aws_eks_node_group.main
  ]

}


# ------------------------------------------------------------
# 2. IAM Role for Amazon EBS CSI Driver
# ------------------------------------------------------------

resource "aws_iam_role" "ebs_csi_role" {

  name = "${var.project_name}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

}


# ------------------------------------------------------------
# 3. Attach EBS CSI IAM Permissions
# ------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {

  role = aws_iam_role.ebs_csi_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"

}


# ------------------------------------------------------------
# 4. Install Amazon EBS CSI Driver as EKS Managed Add-on
# ------------------------------------------------------------

resource "aws_eks_addon" "ebs_csi_driver" {

  cluster_name = aws_eks_cluster.eks.name

  addon_name = "aws-ebs-csi-driver"

  pod_identity_association {
    service_account = "ebs-csi-controller-sa"

    role_arn = aws_iam_role.ebs_csi_role.arn
  }

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.ebs_csi_policy
  ]

}
