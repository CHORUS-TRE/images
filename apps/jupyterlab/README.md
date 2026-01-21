# JupyterLab

JupyterLab Desktop application for interactive Python development and data analysis.

## Description

This container provides JupyterLab Desktop with two Python environments:

1. **jlab_env** - JupyterLab kernel environment with:
   - ipykernel
   - jupyterlab
   - nb_conda_kernels
   - pip

2. **bioinformatics_env** - Scientific computing environment with ipykernel and packages:
   - Data science: joblib, pandas, numpy, scipy, matplotlib, seaborn
   - Machine learning: scikit-survival
   - NLP: nltk, spacy
   - Computer vision: opencv
   - Visualization/apps: pillow, streamlit
   - Statistics: lifelines
   - Utilities: tqdm

Both environments have `ipykernel` installed and are available as kernel options in JupyterLab.

## Resource Requirements

**Important:** JupyterLab Desktop is an Electron/Chromium-based application requiring sufficient resources.

### Minimum Requirements

```yaml
resources:
  requests:
    cpu: "1000m"
    memory: "3Gi"
  limits:
    cpu: "3"
    memory: "6Gi"
```

### Shared Memory

JupyterLab Desktop requires at least **512Mi** of shared memory (`/dev/shm`). The default 64Mi causes blank pages and rendering failures.

```yaml
volumes:
- name: dshm
  emptyDir:
    medium: Memory
    sizeLimit: 512Mi
```
