#!/usr/bin/env make

.PHONY: run_website install_kind install_kubectl create_kind_cluster \
	create_docker_registry connect_registry_to_kind_network \
	connect_registry_to_kind create_kind_cluster_with_registry \
	delete_kind_cluser delete_docker_registry

run_website:
	docker build -t explorecalifornia.com . && \
		docker run -p 3000:80 -d --name explorecalifornia.com --rm explorecalifornia.com

install_kubectl:
	brew install kubectl || true;

install_kind:
	brew install kind

connect_registry_to_kind_network:
	docker network connect kind local-registry || true;

connect_registry_to_kind: connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yaml;

create_docker_registry:
	if ! docker ps | grep -q 'local-registry'; \
	then docker run -d -p 2000:2000 --name local-registry --restart=always registry:2; \
	else echo "---> local-registry is already running. There's nothing to do here."; \
	fi

create_kind_cluster: install_kind install_kubectl create_docker_registry
	kind create cluster --image=kindest/node:v1.21.12 --name explorecalifornia.com --config ./kind_config.yaml || true
	kubectl get nodes

create_kind_cluster_with_registry: delete_kind_cluster
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind && docker ps

delete_kind_cluster: delete_docker_registry
	kind delete cluster --name explorecalifornia.com || true

delete_docker_registry:
	docker container stop local-registry && docker container rm local-registry || true

disconnect_kind_registry:
	docker network disconnect kind local-registry || true

connect_kind_registry:
	docker network connect kind local-registry || true

kubectl_kill_all:
	kubectl delete all --all --all-namespaces || true