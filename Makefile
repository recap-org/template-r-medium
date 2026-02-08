export

# ---- Define important paths ----
# R targets
LIBS = $(wildcard ./src/lib/*.R)

# Main targets
all: ./out/src/main.pdf
.PHONY: all fresh clear-cache tests


# ---- Build rules ----

# Step 1: Data
./out/src/data.pdf: ./src/data.qmd $(R_LIBS)
	@echo "🗄️ $(GREEN_START)Data processing$(GREEN_END)"
	@$(call build_qmd,$<)

# Step 2: Analysis
./out/src/main.pdf: ./src/main.qmd ./out/src/data.pdf $(R_LIBS)
	@echo "📊 $(GREEN_START)Running analysis$(GREEN_END)"
	@$(call build_qmd,$<)

# ---- Utility targets ----

fresh: ## Delete all targets
	@echo "😵 $(GREEN_START)Deleting all targets and intermediary files...$(GREEN_END)"
	@find ./out -type f -name "*.pdf" -delete
	@find ./assets/tables -type f ! -name ".gitignore" -delete
	@find ./assets/figures -type f ! -name ".gitignore" -delete
	@find ./data/processed -type f ! -name ".gitignore" -delete
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"

clear-cache: ## Clear cache of .qmd files
	@echo ""📦 $(GREEN_START)Clearing cache...$(GREEN_END)""
	@find ./src -depth -type d -name "*_cache" -exec rm -rf {} \;
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"

tests: ## Run tests
	@echo "🧪 $(GREEN_START)Running tests...$(GREEN_END)"
	@Rscript -e "testthat::test_dir('tests')"

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)

# ---- functions ----

# build_qmd
# -----------
# Renders a Quarto document (.qmd) and generates a PDF output in the ./out directory
# (e.g., ./src/analysis/main.qmd -> ./bin/src/analysis/main.pdf)
# Arguments:
#   $1 - Path to the .qmd file (e.g., ./src/analysis/main.qmd)
define build_qmd
	$(eval TARGET := $(patsubst %.qmd,out/%.pdf,$(1)))
	@echo "📄 $(GREEN_START)Rendering $(1) -> $(TARGET)...$(GREEN_END)"
	@quarto render $(1)
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"
endef

# build_R
# -----------
# Run an R script
# Arguments:
#   $1 - Path to the .R file (e.g., ./src/lib/io.R)
define build_R
	@echo "📄 $(GREEN_START)Running $(1)...$(GREEN_END)"
	@Rscript $(1)
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"
endef

# --- I/O colors ---
GREEN_START = \033[1;32m
GREEN_END = \033[0m
