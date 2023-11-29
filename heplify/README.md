# Heplify Client on Docker

![heplify](https://img.shields.io/badge/heplify-000000?style=for-the-badge&logo=heplify&logoColor=white)
![imgsize](https://img.shields.io/docker/image-size/mich43l/hep-cli?color=grey&style=flat-square)

### Pull from hub
```
docker pull mich43l/hep-cli
```

### Build from source
```
git clone https://github.com/mach1el/docker-library.git && cd docker-library/heplify
docker buildx build --platform linux/amd64 -t hep-cli .
```

### Run
* *docker run -tid --rm --name=hep-cli --network=host -e HEP_SERVER=10.10.20.10 mich43l/hep-cli*