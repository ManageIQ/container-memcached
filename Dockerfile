FROM registry.access.redhat.com/ubi9/ubi-minimal:latest AS manifest

COPY .git /tmp/.git

RUN cd /tmp && \
    sha=$(cat .git/HEAD | cut -d " " -f 2) && \
    if [[ "$(cat .git/HEAD)" == "ref:"* ]]; then sha=$(cat .git/$sha); fi && \
    echo "$(date +"%Y%m%d%H%M%S")-$sha" > /tmp/BUILD

FROM registry.access.redhat.com/ubi9/ubi

# Memcached image for OpenShift ManageIQ

MAINTAINER ManageIQ https://github.com/ManageIQ/manageiq-appliance-build

LABEL io.k8s.description="Memcached is a general-purpose distributed memory object caching system" \
      io.k8s.display-name="Memcached" \
      io.openshift.expose-services="11211:memcached" \
      io.openshift.tags="memcached" \
      name="Memcached" \
      summary="Memcached Image" \
      vendor="ManageIQ" \
      description="Memcached is a general-purpose distributed memory object caching system"

EXPOSE 11211

RUN dnf -y --disableplugin=subscription-manager --setopt=tsflags=nodocs update && \
    dnf install --setopt=tsflags=nodocs -y memcached && \
    dnf clean all

COPY container-assets/container-entrypoint /usr/bin

RUN mkdir -p /opt/manageiq/manifest
COPY --from=manifest /tmp/BUILD /opt/manageiq/manifest

# memcached user is uid 998
USER 998
ENTRYPOINT ["container-entrypoint"]
CMD ["memcached"]
