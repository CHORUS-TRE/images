# Tune Insight JupyterLab

JupyterLab Desktop application with the [Tune Insight](https://pypi.org/project/tuneinsight/) library pre-installed for privacy-preserving data analysis.

## Description

This container provides JupyterLab Desktop with two Python environments:

1. **jlab_env** - Base JupyterLab environment with standard packages
2. **tuneinsight_env** - Scientific computing environment with:
   - Data science packages (pandas, numpy, scipy, matplotlib, seaborn)
   - Machine learning libraries (scikit-survival)
   - NLP tools (nltk, spacy)
   - Computer vision (opencv)
   - **Tune Insight library** for privacy-preserving analytics

## Included Notebooks

Two starter notebooks are automatically copied to your home directory:
- `00-Check.ipynb` - Environment verification and setup check
- `01-Quickstart.ipynb` - Quick start guide for Tune Insight

## Resource Requirements

**Important:** JupyterLab Desktop is an Electron/Chromium-based application that requires sufficient resources to run properly.

### Minimum Requirements

```yaml
resources:
  requests:
    cpu: "1000m"
    memory: "3Gi"
    ephemeral-storage: "1Gi"
```

### Shared Memory

**Critical:** JupyterLab Desktop requires at least **512Mi** of shared memory (`/dev/shm`). The default 64Mi is insufficient and will cause blank pages or rendering failures.

Ensure your workbench specification includes:

```yaml
spec:
  template:
    spec:
      containers:
      - name: tune-insight
        volumeMounts:
        - name: dshm
          mountPath: /dev/shm
      volumes:
      - name: dshm
        emptyDir:
          medium: Memory
          sizeLimit: 512Mi
```

### Symptoms of Insufficient Resources

- Blank pages when creating new notebooks
- Renderer process failures

## Using the Application

### Selecting a Kernel

When creating a new notebook, you can choose between:
- **Python [conda env:jlab_env]** - Standard Python environment
- **Python [conda env:tuneinsight_env]** - Environment with Tune Insight and scientific packages

To use Tune Insight, select the `tuneinsight_env` kernel.

### Verifying Installation

```python
import tuneinsight
print(f"Tune Insight version: {tuneinsight.__version__}")
```
## Notes

- This application persists `.jupyter` configuration to workspace storage
- The `nb_conda_kernels` package automatically discovers conda environments with ipykernel

