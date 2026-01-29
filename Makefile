export

# --- I/O colors ---
GREEN_START = \033[1;32m
GREEN_END = \033[0m

# ---- Define target paths ----
# R targets
R_LIBS = $(wildcard ./src/lib/*.R)
R_DATA = $(patsubst ./src/data/%.qmd, ./bin/src/data/%.pdf, $(wildcard ./src/data/*.qmd))
R_ANALYSIS = $(patsubst ./src/analysis/%.qmd, ./bin/src/analysis/%.pdf, $(wildcard ./src/analysis/*.qmd))

# LaTex targets
PDF_FILES = $(patsubst ./tex/%,./bin/tex/%.pdf,$(wildcard ./tex/*)) 


# ---- Main targets ----
all: $(R_ANALYSIS) 
.SECONDARY: $(R_DATA)
.PHONY: all clean fresh clear-cache initialize

# ---- functions ----

# build_tex
# -----------
# Compiles a LaTeX file in ./tex/DIR/main.tex and copies the resulting PDF to ./bin/tex/DIR.pdf
# Arguments:
#   $1 - Path to the LaTeX main.tex file (e.g., tex/article/main.tex)
define build_tex
	$(eval TARGET := $(patsubst tex/%/main.tex,bin/tex/%.pdf,$(1)))
	@echo "📝 $(GREEN_START)Compiling $(1) -> $(TARGET)...$(GREEN_END)"
	@mkdir -p ./bin/tex/
	@cd $(dir $(1)) &&\
		latexmk -pdf -quiet\
		-interaction=nonstopmode $(notdir $(1))
	@cp $(basename $(1)).pdf $(TARGET)
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"
endef


# build_qmd
# -----------
# Renders a Quarto document (.qmd) and generates a PDF output in the bin directory
# Arguments:
#   $1 - Path to the .qmd file (e.g., src/analysis/main.qmd -> bin/src/analysis/main.pdf)
define build_qmd
	$(eval TARGET := $(patsubst %.qmd,bin/%.pdf,$(1)))
	@echo "📄 $(GREEN_START)Rendering $(1) -> $(TARGET)...$(GREEN_END)"
	@quarto render $(1)
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"
endef

define build_R
	@echo "📄 $(GREEN_START)Running $(1)...$(GREEN_END)"
	@Rscript $(1)
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"
endef

# ---- Step 1: Data ----
./bin/src/data/%.pdf: ./src/data/%.qmd $(R_LIBS)
	@echo "🗄️ $(GREEN_START)Data processing$(GREEN_END)"
	@$(call build_qmd,$<)

# ---- Step 2: Analysis ----
./bin/src/analysis/%.pdf: ./src/analysis/%.qmd $(R_DATA) $(R_LIBS)
	@echo "📊 $(GREEN_START)Running analysis$(GREEN_END)"
	@$(call build_qmd,$<)

# Delete all targets
fresh: 
	@echo "😵 $(GREEN_START)Deleting all targets and intermediary files...$(GREEN_END)"
	@find ./bin -type f -name "*.pdf" -delete
	@find ./bin -type f -name "*.log" -delete
	@find ./bin -type f -name "*.log" -delete
	@find ./data/processed -type f ! -name ".gitignore" -delete
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"

# Clear cache of .qmd files
clear-cache: 
	@echo ""📦 $(GREEN_START)Clearing cache...$(GREEN_END)""
	@find ./src -depth -type d -name "*_cache" -exec rm -rf {} \;
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"

