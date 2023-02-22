#!/bin/sh
#Container runtime  should use external EBS volume as root dir
if [[ "${container_runtime}" = "containerd" ]]; then
    systemctl stop containerd; rm -rf /var/lib/containerd && mkdir -p /var/lib/containerd && mkfs -t xfs ${device_docker} && mount ${device_docker} /var/lib/containerd && systemctl start containerd
elif [[ "${container_runtime}" = "dockerd" ]]; then
    systemctl stop docker; rm -rf /var/lib/docker && mkdir -p /var/lib/docker && mkfs -t xfs ${device_docker} && mount ${device_docker} /var/lib/docker && systemctl start docker
else
    echo "Container runtime ${container_runtime} is not supported." && exit 1
fi
/etc/eks/bootstrap.sh --apiserver-endpoint ${cluster_endpoint} --b64-cluster-ca ${cluster_cert} --container-runtime ${container_runtime} ${cluster_name} ${kubelet-extra-args}
${more_additional_user_data}
