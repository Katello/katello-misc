VERSION="2.1"
FOREMAN_VERSION="1.7"

#RHEL 6

koji-katello clone-tag katello-nightly-rhel6 katello-$VERSION-rhel6
koji-katello clone-tag katello-thirdparty-rhel6 katello-$VERSION-thirdparty-rhel6

koji-katello add-tag katello-$VERSION-rhel6-build  --arches=x86_64
koji-katello add-tag katello-$VERSION-rhel6-override
koji-katello add-tag-inheritance katello-$VERSION-rhel6-build katello-$VERSION-rhel6-override
koji-katello add-tag-inheritance katello-$VERSION-rhel6-override katello-$VERSION-rhel6
koji-katello add-tag-inheritance katello-$VERSION-rhel6 katello-$VERSION-thirdparty-rhel6

#plugins needs to take higher precedence 
koji-katello add-tag-inheritance katello-$VERSION-rhel6-build foreman-plugins-$FOREMAN_VERSION-rhel6-override --priority=2
koji-katello add-tag-inheritance katello-$VERSION-rhel6-build foreman-$FOREMAN_VERSION-rhel6 --priority=3

koji-katello add-target katello-$VERSION-rhel6 katello-$VERSION-rhel6-build

koji-katello add-external-repo rhel-6.6-server -t katello-$VERSION-rhel6-build
koji-katello add-external-repo rhel-6.6-server-optional -t katello-$VERSION-rhel6-build
koji-katello add-external-repo epel-6 -t katello-$VERSION-rhel6-build
koji-katello add-external-repo rhscl-1.1-rhel-6 -t katello-$VERSION-rhel6-build
koji-katello add-external-repo jpackage-5.0-generic-free -t katello-$VERSION-rhel6-build

BUILD_PKGS=`koji-katello  list-groups katello-nightly-rhel6-build build |  tail -n +2 |   awk -F ':' '{print $1}'    | tr  "\\n" " "`
SRPM_BUILD_PKGS=`koji-katello  list-groups katello-nightly-rhel6-build srpm-build |  tail -n +2 |   awk -F ':' '{print $1}'    | tr  "\\n" " "`
koji-katello add-group katello-$VERSION-rhel6-build build
koji-katello add-group katello-$VERSION-rhel6-build srpm-build
koji-katello add-group-pkg katello-$VERSION-rhel6-build build $BUILD_PKGS
koji-katello add-group-pkg katello-$VERSION-rhel6-build srpm-build $SRPM_BUILD_PKGS

# need to regen-repo on the tag before package groups show up
koji-katello regen-repo katello-$VERSION-rhel6-build

#RHEL 7

koji-katello clone-tag katello-nightly-rhel7 katello-$VERSION-rhel7
koji-katello clone-tag katello-thirdparty-rhel7 katello-$VERSION-thirdparty-rhel7

koji-katello add-tag katello-$VERSION-rhel7-build  --arches=x86_64
koji-katello add-tag katello-$VERSION-rhel7-override
koji-katello add-tag-inheritance katello-$VERSION-rhel7-build katello-$VERSION-rhel7-override
koji-katello add-tag-inheritance katello-$VERSION-rhel7-override katello-$VERSION-rhel7
koji-katello add-tag-inheritance katello-$VERSION-rhel7 katello-$VERSION-thirdparty-rhel7
koji-katello add-tag-inheritance katello-$VERSION-rhel7-build foreman-plugins-$FOREMAN_VERSION-rhel7-override --priority=2
koji-katello add-tag-inheritance katello-$VERSION-rhel7-build foreman-$FOREMAN_VERSION-rhel7 --priority=3

koji-katello add-target katello-$VERSION-rhel7 katello-$VERSION-rhel7-build

koji-katello add-external-repo rhel-7.0-server -t katello-$VERSION-rhel7-build
koji-katello add-external-repo rhel-7.0-server-optional -t katello-$VERSION-rhel7-build
koji-katello add-external-repo epel-7-beta -t katello-$VERSION-rhel7-build
koji-katello add-external-repo rhscl-1.1-rhel-7 -t katello-$VERSION-rhel7-build
koji-katello add-external-repo jpackage-5.0-generic-free -t katello-$VERSION-rhel7-build

BUILD_PKGS=`koji-katello  list-groups katello-nightly-rhel7-build build |  tail -n +2 |   awk -F ':' '{print $1}'    | tr  "\\n" " "`
SRPM_BUILD_PKGS=`koji-katello  list-groups katello-nightly-rhel7-build srpm-build |  tail -n +2 |   awk -F ':' '{print $1}'    | tr  "\\n" " "`
koji-katello add-group katello-$VERSION-rhel7-build build
koji-katello add-group katello-$VERSION-rhel7-build srpm-build
koji-katello add-group-pkg katello-$VERSION-rhel7-build build $BUILD_PKGS
koji-katello add-group-pkg katello-$VERSION-rhel7-build srpm-build $SRPM_BUILD_PKGS

koji-katello regen-repo katello-$VERSION-rhel7-build

#RHEL 5

koji-katello clone-tag katello-nightly-rhel5 katello-$VERSION-rhel5

koji-katello add-tag katello-$VERSION-rhel5-build  --arches=x86_64,i386
koji-katello add-tag katello-$VERSION-rhel5-override
koji-katello add-tag-inheritance katello-$VERSION-rhel5-build katello-$VERSION-rhel5-override
koji-katello add-tag-inheritance katello-$VERSION-rhel5-override katello-$VERSION-rhel5
koji-katello add-target katello-$VERSION-rhel5 katello-$VERSION-rhel5-build

koji-katello add-external-repo rhel-5.9-server -t katello-$VERSION-rhel5-build
koji-katello add-external-repo epel-5 -t katello-$VERSION-rhel5-build

BUILD_PKGS=`koji-katello  list-groups katello-nightly-rhel5-build build |  tail -n +2 |   awk -F ':' '{print $1}'    | tr  "\\n" " "`
SRPM_BUILD_PKGS=`koji-katello  list-groups katello-nightly-rhel5-build srpm-build |  tail -n +2 |   awk -F ':' '{print $1}'    | tr  "\\n" " "`
koji-katello add-group katello-$VERSION-rhel5-build build
koji-katello add-group katello-$VERSION-rhel5-build srpm-build
koji-katello add-group-pkg katello-$VERSION-rhel5-build build $BUILD_PKGS
koji-katello add-group-pkg katello-$VERSION-rhel5-build srpm-build $SRPM_BUILD_PKGS

koji-katello regen-repo katello-$VERSION-rhel5-build

#Pulp RHEL 6

koji-katello clone-tag katello-thirdparty-pulp-rhel6 katello-$VERSION-thirdparty-pulp-rhel6

koji-katello add-tag katello-$VERSION-thirdparty-pulp-rhel6-build --arches=x86_64
koji-katello add-tag-inheritance katello-$VERSION-thirdparty-pulp-rhel6-build katello-$VERSION-thirdparty-pulp-rhel6
koji-katello add-target katello-$VERSION-thirdparty-pulp-rhel6 katello-$VERSION-thirdparty-pulp-rhel6-build

koji-katello add-external-repo  rhel-6.6-server -t katello-$VERSION-thirdparty-pulp-rhel6-build
koji-katello add-external-repo  rhel-6.6-server-optional -t katello-$VERSION-thirdparty-pulp-rhel6-build
koji-katello add-external-repo  epel-6 -t katello-$VERSION-thirdparty-pulp-rhel6-build

koji-katello regen-repo katello-$VERSION-thirdparty-pulp-rhel6-build

#Pulp RHEL 7

koji-katello clone-tag katello-thirdparty-pulp-rhel7 katello-$VERSION-thirdparty-pulp-rhel7

koji-katello add-tag katello-$VERSION-thirdparty-pulp-rhel7-build --arches=x86_64
koji-katello add-tag-inheritance katello-$VERSION-thirdparty-pulp-rhel7-build katello-$VERSION-thirdparty-pulp-rhel7
koji-katello add-target katello-$VERSION-thirdparty-pulp-rhel7 katello-$VERSION-thirdparty-pulp-rhel7-build

koji-katello add-external-repo  rhel-7.0-server -t katello-$VERSION-thirdparty-pulp-rhel7-build
koji-katello add-external-repo  rhel-7.0-server-optional -t katello-$VERSION-thirdparty-pulp-rhel7-build
koji-katello add-external-repo  epel-7-beta -t katello-$VERSION-thirdparty-pulp-rhel7-build

koji-katello regen-repo katello-$VERSION-thirdparty-pulp-rhel7-build

#candlepin rhel6
koji-katello clone-tag katello-thirdparty-candlepin-rhel6 katello-$VERSION-thirdparty-candlepin-rhel6

koji-katello add-tag katello-$VERSION-thirdparty-candlepin-rhel6-build --arches=x86_64
koji-katello add-tag katello-$VERSION-thirdparty-candlepin-rhel6-override
koji-katello add-tag-inheritance katello-$VERSION-thirdparty-candlepin-rhel6-build katello-$VERSION-thirdparty-candlepin-rhel6-override
koji-katello add-tag-inheritance katello-$VERSION-thirdparty-candlepin-rhel6-override katello-$VERSION-thirdparty-candlepin-rhel6

koji-katello add-target katello-$VERSION-thirdparty-candlepin-rhel6 katello-$VERSION-thirdparty-candlepin-rhel6-build

koji-katello add-external-repo rhel-6.6-server -t katello-$VERSION-thirdparty-candlepin-rhel6-build
koji-katello add-external-repo rhel-6.6-server-optional -t katello-$VERSION-thirdparty-candlepin-rhel6-build
koji-katello add-external-repo epel-6 -t katello-$VERSION-thirdparty-candlepin-rhel6-build

koji-katello regen-repo katello-$VERSION-thirdparty-candlepin-rhel6-build

#candlepin RHEL 7
koji-katello clone-tag katello-thirdparty-candlepin-rhel7 katello-$VERSION-thirdparty-candlepin-rhel7

koji-katello add-tag katello-$VERSION-thirdparty-candlepin-rhel7-build --arches=x86_64
koji-katello add-tag katello-$VERSION-thirdparty-candlepin-rhel7-override
koji-katello add-tag-inheritance katello-$VERSION-thirdparty-candlepin-rhel7-build katello-$VERSION-thirdparty-candlepin-rhel7-override
koji-katello add-tag-inheritance katello-$VERSION-thirdparty-candlepin-rhel7-override katello-$VERSION-thirdparty-candlepin-rhel7

koji-katello add-target katello-$VERSION-thirdparty-candlepin-rhel7 katello-$VERSION-thirdparty-candlepin-rhel7-build

koji-katello add-external-repo rhel-7.0-server -t katello-$VERSION-thirdparty-candlepin-rhel7-build
koji-katello add-external-repo rhel-7.0-server-optional -t katello-$VERSION-thirdparty-candlepin-rhel7-build
koji-katello add-external-repo epel-7-beta -t katello-$VERSION-thirdparty-candlepin-rhel7-build

koji-katello regen-repo katello-$VERSION-thirdparty-candlepin-rhel7-build

