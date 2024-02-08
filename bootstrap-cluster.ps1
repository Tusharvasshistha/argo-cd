param
(
    [parameter(Mandatory = $true)][string]
    $clusterName
)

function Bootstrap-Component {
    param
    (
        [parameter(Mandatory = $true)][string]
        $componentName,
        [parameter(Mandatory = $false)][bool]
        $wait=$false,
        [parameter(Mandatory = $false)][string]
        $namespace
    )
    
    Write-Host "Bootstrapping $componentName..."
    kustomize build "kustomize/$componentName/overlays/$clusterName" | kubectl apply --server-side -f -

    if ($LASTEXITCODE -ne 0) {
        Write-Host "An error was encountered while boostrapping $componentName" -ForegroundColor Red
        Exit 1
    }

    if ($wait) {
        kubectl wait --for=condition=Ready pod --all -n $namespace 
    }

    Write-Host "Finished bootrapping $componentName" -ForegroundColor Green
    Write-Host ""
}

$ErrorActionPreference = "Stop"

if (!(Get-Command kustomize -ErrorAction SilentlyContinue)) {
    Write-Host "Kustomize is not installed. Please install Kustomize and try again." -ForegroundColor Red
    Exit 1
}

if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "Kubectl is not installed. Please install Kubectl and try again." -ForegroundColor Red
    Exit 1
}

$currentContext = kubectl config current-context
$currentCluster = kubectl config view --minify --output 'jsonpath={.clusters[].name}'

if ($clusterName -ne $currentCluster) {
    Write-Host "The chosen cluster: [$clusterName] does not match the cluster name in the current context: [$currentCluster]" -ForegroundColor Red
    Write-Host "The current Kube context is: [$currentContext]" -ForegroundColor Red
    Write-Host "Please set the appropriate context for the target cluster and try again." -ForegroundColor Red
    Exit 1
}
#Bootstrap-Component -componentName "keda" -wait
#Bootstrap-Component -componentName "external-secrets" -wait $true -namespace "external-secrets"
#Bootstrap-Component -componentName "argocd" -wait $true -namespace "argocd"
#Bootstrap-Component -componentName "argocd-config"
#Bootstrap-Component -componentName "gitops-connector"
#Bootstrap-Component -componentName "self-manage"
Bootstrap-Component -componentName "keda" -wait

Write-Host "Cluster has been bootstrapped successfully!" -ForegroundColor Green