# argo-cd

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kedainstall
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: keda
    server: https://kubernetes.default.svc
  project: default
  source:
    path: ./
    repoURL: https://github.com/Tusharvasshistha/argo-cd
    targetRevision: refs/heads/main
