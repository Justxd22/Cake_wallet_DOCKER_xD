# <----- how to run ----->
# mkdir build
# docker build -f cakeRELEASE.Dockerfile -t cake .
# docker create -it --name cake cake bash
# docker cp cake:/build/. build/



# Base image with Flutter
FROM instrumentisto/flutter:3.19.6

# Set environment variables
ENV STORE_PASS=test@cake_wallet \
    KEY_PASS=test@cake_wallet

SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt update && \
    apt-get install -y \
    curl \
    unzip \
    automake \
    build-essential \
    file \
    pkg-config \
    git \
    python-is-python3 \
    libtool \
    libtinfo5 \
    cmake \
    openjdk-8-jre-headless \
    clang

# Set up Android environment
RUN mkdir -p /opt/android && \
    cd /opt/android && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    cargo install cargo-ndk && \
    git clone https://github.com/cake-tech/cake_wallet.git && \
    cd cake_wallet/scripts/android/ && \
    ./install_ndk.sh && \
    source ./app_env.sh cakewallet && \
    chmod +x pubspec_gen.sh && \
    ./app_config.sh

# Install Go
RUN wget https://go.dev/dl/go1.23.1.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz && \
    export PATH=$PATH:/usr/local/go/bin && \
    go install golang.org/x/mobile/cmd/gomobile@latest && \
    export PATH=$PATH:~/go/bin && \
    gomobile init

# Build binaries (this step may take a while)
RUN cd /opt/android/cake_wallet/scripts/android/ && \
    source ./app_env.sh cakewallet && \
    ./build_monero_all.sh

# Fetch Flutter dependencies
RUN cd /opt/android/cake_wallet && \
    flutter pub get

# Build mwebd
RUN cd /opt/android/cake_wallet/scripts/android/ && \
    ./build_mwebd.sh --dont-install

# keystore
RUN cd /opt/android/cake_wallet/android/app && \
    keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias testKey -noprompt \
    -dname "CN=CakeWallet, OU=CakeWallet, O=CakeWallet, L=Florida, S=America, C=USA" \
    -storepass $STORE_PASS -keypass $KEY_PASS

# key properties
RUN cd /opt/android/cake_wallet && \
    flutter packages pub run tool/generate_android_key_properties.dart \
    keyAlias=testKey storeFile=key.jks storePassword=$STORE_PASS keyPassword=$KEY_PASS

# Localization
RUN cd /opt/android/cake_wallet && \
    flutter packages pub run tool/generate_localization.dart

# Final build step
RUN cd /opt/android/cake_wallet && \
    ./model_generator.sh

# ---- Add Secrets with Placeholders ----
RUN cd /opt/android/cake_wallet && \
    touch lib/.secrets.g.dart && \
    touch cw_evm/lib/.secrets.g.dart && \
    touch cw_solana/lib/.secrets.g.dart && \
    touch cw_core/lib/.secrets.g.dart && \
    touch cw_nano/lib/.secrets.g.dart && \
    touch cw_tron/lib/.secrets.g.dart && \
    echo "const salt = '00000000000000000000000000000000';" > lib/.secrets.g.dart && \
    echo "const keychainSalt = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const key = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const walletSalt = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const shortKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const backupSalt = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const backupKeychainSalt = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const changeNowApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const changeNowApiKeyDesktop = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const wyreSecretKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const wyreApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const wyreAccountId = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const moonPayApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const moonPaySecretKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const sideShiftAffiliateId = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const simpleSwapApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const simpleSwapApiKeyDesktop = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const onramperApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const anypayToken = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const ioniaClientId = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const twitterBearerToken = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const trocadorApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const trocadorExchangeMarkup = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const anonPayReferralCode = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const fiatApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const payfuraApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const ankrApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const etherScanApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const polygonScanApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const etherScanApiKey = '00000000000000000000000000000000';" >> cw_evm/lib/.secrets.g.dart && \
    echo "const moralisApiKey = '00000000000000000000000000000000';" >> cw_evm/lib/.secrets.g.dart && \
    echo "const chatwootWebsiteToken = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const exolixApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const robinhoodApplicationId = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const exchangeHelperApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const walletConnectProjectId = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const moralisApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const polygonScanApiKey = '00000000000000000000000000000000';" >> cw_evm/lib/.secrets.g.dart && \
    echo "const ankrApiKey = '00000000000000000000000000000000';" >> cw_solana/lib/.secrets.g.dart && \
    echo "const testCakePayApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const cakePayApiKey = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const authorization = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const CSRFToken = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const quantexExchangeMarkup = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const nano2ApiKey = '00000000000000000000000000000000';" >> cw_nano/lib/.secrets.g.dart && \
    echo "const nanoNowNodesApiKey = '00000000000000000000000000000000';" >> cw_nano/lib/.secrets.g.dart && \
    echo "const tronGridApiKey = '00000000000000000000000000000000';" >> cw_tron/lib/.secrets.g.dart && \
    echo "const tronNowNodesApiKey = '00000000000000000000000000000000';" >> cw_tron/lib/.secrets.g.dart && \
    echo "const letsExchangeBearerToken = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const letsExchangeAffiliateId = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const stealthExBearerToken = '00000000000000000000000000000000';" >> lib/.secrets.g.dart && \
    echo "const stealthExAdditionalFeePercent = '00000000000000000000000000000000';" >> lib/.secrets.g.dart

# Build APK
RUN cd /opt/android/cake_wallet && \
    flutter build apk --release --split-per-abi

# copy apk
RUN mkdir /build/ && \
    cp /opt/android/cake_wallet/build/app/outputs/flutter-apk/* /build/ && \
    cp /opt/android/cake_wallet/build/app/outputs/apk/release/ /build/

# Zip the build folder
RUN cd /build && \
    zip -r build_output.zip . && \
    echo "Zipped build folder created at /build/build_output.zip"

# Install curl (required for upload)
RUN apt-get install -y curl

# Upload the zip file to bashupload and log the link
RUN UPLOAD_URL=$(curl bashupload.com -T /build/build_output.zip) && \
    echo "Build file uploaded successfully. Download link: $UPLOAD_URL"
