FROM busybox as test

ADD docker-installer/install_cni_plugins.sh /script/install_cni_plugins.sh
ADD docker-installer/test_install_cni_plugins.sh /script/test_install_cni_plugins.sh
WORKDIR /script
RUN /script/test_install_cni_plugins.sh

FROM busybox as build
ARG TAG
# ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
# ARG TARGETVARIANT
# ARG BUILDPLATFORM
# ARG BUILDOS
# ARG BUILDARCH
# ARG BUILDVARIANT
# RUN echo TARGETPLATFORM=$TARGETPLATFORM
# RUN echo TARGETOS=$TARGETOS
# RUN echo TARGETARCH=$TARGETARCH
# RUN echo TARGETVARIANT=$TARGETVARIANT
# RUN echo BUILDPLATFORM=$BUILDPLATFORM
# RUN echo BUILDOS=$BUILDOS
# RUN echo BUILDARCH=$BUILDARCH
# RUN echo BUILDVARIANT=$BUILDVARIANT
# Use automatic buildx platform vars: https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
COPY release-$TAG/cni-plugins-$TARGETOS-$TARGETARCH-$TAG.tgz release.tgz
COPY release-$TAG/cni-plugins-$TARGETOS-$TARGETARCH-$TAG.tgz.sha512 release.tgz.sha512
RUN set -eux; \
    mkdir -p /opt/cni/bin; \
    tar -xvf release.tgz -C /opt/cni/bin;

# This is the final, minimal container
FROM busybox as final
COPY docker-installer/install_cni_plugins.sh /script/install_cni_plugins.sh
COPY --from=build /opt/cni/bin /opt/cni/bin
WORKDIR /opt/cni/bin
VOLUME /host/opt/cni/bin
CMD ["/script/install_cni_plugins.sh","/opt/cni/bin","/host/opt/cni/bin"]
