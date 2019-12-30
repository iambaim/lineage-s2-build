# lineage-s2-build

## Requirements
1. Scaleway CLI (https://github.com/scaleway/scaleway-cli)
2. Your Scaleway account organization ID and secret TOKEN
3. Your certificates file (for signing builds, cf. https://wiki.lineageos.org/signing_builds.html) inside the `android-certs.tgz` file and placed in the same directory as the `create-buildbox.sh` file

## Start the build
`SCW_TOKEN=<secret TOKEN> SCW_ORGANIZATION=<organization ID> ./create-buildbox.sh`

