# ITK-SNAP Medical Image Segmentation Tool

See [ITK-SNAP](http://www.itksnap.org/)

## Debug

ITK-SNAP is a Qt application that just fail to start. The following snippets enables more debugging information.

```shell
docker run --rm -it --entrypoint itksnap -e QT_DEBUG_PLUGINS=1 registry.build.chorus-tre.local/itksnap
```
