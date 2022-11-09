# Steps:
# - Scale down existing pods (any mounting the PV/PVC)
# - Wait until pods all torn down
# - Grab PV name/ref from PVC
# - Patch retain policy into PV
# - Patch out uid/resourceVersion from claimRef in PV
# - Patch name/namespace from claimRef in PV to the new name/namespace
# - Patch out uid/resourceVersion
# - Upgrade, PVC will automatically use the existing PVC *magic*

kubectl scale deploy --replicas 0 twistlock-console -n twistlock
while [[ $(kubectl get pod -l name="twistlock-console" -n twistlock --output name | wc -l) -gt 0 ]]; do
  sleep 10
done
pv_name=$(kubectl get pvc -n twistlock twistlock-console -o jsonpath='{.spec.volumeName}')
kubectl get pv $pv_name -o yaml > ~/.pv.yaml
kubectl patch pv $pv_name -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
kubectl patch pv $pv_name --type=json -p="[{'op': 'remove', 'path': '/spec/claimRef/uid'}]"
kubectl patch pv $pv_name --type=json -p="[{'op': 'remove', 'path': '/spec/claimRef/resourceVersion'}]"
kubectl patch pv $pv_name -p '{"spec":{"claimRef":{"namespace":"prisma-cloud"}}}'
