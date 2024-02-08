#!/bin/sh
#
# This hook script generates the LLD (low level definition) manifests
# for all Kustomize projects under the Kustomize folder.

for project in "kustomize"/*/; do
	if [ -d "$project" ]; then
		for overlay in "$project"overlays/*/; do
			if [ -d "$overlay" ]; then
				echo "Running Kustomize to generate LLD manifest for: $overlay"
				target="$overlay"lld
				mkdir -p $target
				kustomize build $overlay > "$target/manifest.yaml"
				git add "$target/manifest.yaml"
			fi
		done
	fi
done