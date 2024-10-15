resource "kubernetes_manifest" "cart_svc" {
  depends_on = [module.eks]
  manifest   = yamldecode(file("../k8s/cart-svc.yaml"))
}


resource "kubernetes_manifest" "cart_deploy" {
  depends_on = [module.eks]
  manifest   = yamldecode(file("../k8s/cart-deploy.yaml"))
}



resource "kubernetes_manifest" "cart_hpa" {
  depends_on = [module.eks]
  manifest   = yamldecode(file("../k8s/cart-hpa.yaml"))
}



resource "kubernetes_manifest" "payment_svc" {
  depends_on = [module.eks]
  manifest   = yamldecode(file("../k8s/payment-svc.yaml"))
}


resource "kubernetes_manifest" "payment_deploy" {
  depends_on = [module.eks]
  manifest   = yamldecode(file("../k8s/payment-deploy.yaml"))
}



resource "kubernetes_manifest" "payment_hpa" {
  depends_on = [module.eks]
  manifest   = yamldecode(file("../k8s/payment-hpa.yaml"))
}




resource "kubernetes_manifest" "ingress" {
  depends_on = [module.eks]
  manifest   = yamldecode(file("../k8s/ingress.yaml"))
}
