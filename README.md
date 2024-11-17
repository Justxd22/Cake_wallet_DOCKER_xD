# CakeWallet Docker build

- using instrumentisto/flutter as base
- setup sdk to match one used in CakeWallet workflow PR build
- using pre-built bins from mrcyjanek/monero_c for fast build time
- using gen secert script so it has empty keys (check steps below)

## how to build
1. clone repo 
`git clone https://github.com/Justxd22/Cake_wallet_DOCKER_xD && cd Cake_wallet_DOCKER_xD`
2. you can optionally choose between default pre-built monero_c bins or build them 
    - use `cakeRELEASE.Dockerfile` for pre-built bins
    - use `cakeRELEASE_BUILD_BINS.Dockerfile` for building bins
3. you can optionally Fill in your api keys, skip to use empty values
    - uncomment and fill keys L#119
4. build the docker
```bash
$ mkdir build
$ docker build -f cakeRELEASE.Dockerfile -t cake .
$ docker create -it --name cake cake bash
$ docker cp cake:/build/. build/
```
5. find your apks in `build/` folder or use bashupload link for zipped apks in building logs

:D

## support

- xmr: `433CbZXrdTBQzESkZReqQp1TKmj7MfUBXbc8FkG1jpVTBFxY9MCk1RXPWSG6CnCbqW7eiMTEGFgbHXj3rx3PxZadPgFD3DX`
- xmr: `4ACPJKijtYsBn1vsYdjS6sLavgvvyEVYg54adcHGYepUMFi8sUttk9obNfaRv3TCMZN5pMeHLiTTpHjAdTkLYPDr33BBRh5`
- birdpay: `@_xd222`