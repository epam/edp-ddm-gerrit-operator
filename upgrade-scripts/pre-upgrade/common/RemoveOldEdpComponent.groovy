void call() {
    def gerritEDPComponentOwner = sh(script: "oc get EDPComponents gerrit -o jsonpath={.metadata.ownerReferences[0].kind} -n $NAMESPACE || true", returnStdout: true)
    if (gerritEDPComponentOwner.equals( "Gerrit" )) {
        sh "echo Removing EDP component with deprecated gerrit route..."
        sh "oc delete EDPComponents gerrit -n $NAMESPACE"
    }
}

return this;
