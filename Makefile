# BGFlipper OS — raccourcis de build.
# Ces cibles ne sont que des enrobages autour des scripts de scripts/.

APP ?= bgflipper_splash

.PHONY: help setup overlay build apps flash run clean update-hashes

help: ## Affiche cette aide
	@echo "BGFlipper OS — cibles disponibles :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

setup: ## Clone le firmware officiel épinglé dans ./upstream
	./scripts/setup.sh

overlay: ## Applique la couche de personnalisation sur ./upstream
	./scripts/apply-overlay.sh

build: ## Construit le firmware complet (setup + overlay + fbt)
	./scripts/build.sh

apps: overlay ## Construit tous les FAP utilisateur (.fap)
	cd upstream && ./fbt faps

flash: ## Flashe le firmware + ressources sur un Flipper en USB
	./scripts/flash.sh

run: overlay ## Compile, envoie et lance UNE app :  make run APP=bgflipper_splash
	cd upstream && ./fbt launch APPSRC=applications_user/$(APP)

update-hashes: ## Régénère overlay/UPSTREAM_HASHES.txt depuis l'upstream courant
	./scripts/update-hashes.sh

clean: ## Nettoie les artefacts de build (garde le clone upstream)
	@if [ -d upstream ]; then cd upstream && ./fbt -c || true; fi
	@echo "Nettoyé (le clone upstream est conservé ; 'rm -rf upstream' pour tout retirer)."
