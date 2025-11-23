Repository for my notes

## Docker Image Usage

The image runs with `CMD` `emanote gen /public`.

```
docker run \
  --interactive --tty --rm \
  --volume $(pwd):/data \
  --volume $(pwd)/public:/public \
  ghcr.io/rgoulter/notes:latest
```
