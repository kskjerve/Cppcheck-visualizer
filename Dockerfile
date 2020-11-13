FROM openjdk:alpine

ARG SAXON_VERSION=9.9.1-4

RUN apk --update add git build-base cmake graphviz

WORKDIR /saxon
ADD https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/$SAXON_VERSION/Saxon-HE-$SAXON_VERSION.jar .
RUN chmod +r *.jar
ADD xslt ./
RUN chmod +x xslt

RUN mkdir /cppcheck &&\
    cd /cppcheck &&\
    git clone https://github.com/danmar/cppcheck.git . &&\
    mkdir build &&\
    cd build &&\
    cmake .. &&\
    cmake -DUSE_MATCHCOMPILER=ON -DCMAKE_BUILD_TYPE=MinSizeRel .. &&\
    cmake --build . --config Release &&\
    chmod +x bin/cppcheck &&\
    cp bin/cppcheck ../cppcheck

WORKDIR /viz
ADD dump2dot.xsl convert.sh ./
RUN chmod +x convert.sh

ENV PATH="/saxon:/viz${PATH}"