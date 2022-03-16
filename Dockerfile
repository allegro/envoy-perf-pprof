ARG ENVOY_VERSION
FROM envoyproxy/envoy-debug:$ENVOY_VERSION AS envoy

FROM ubuntu:18.04 AS perf_data_converter

RUN apt update && apt install -y npm g++ git libelf-dev libcap-dev
RUN npm install -g @bazel/bazelisk

RUN git clone https://github.com/google/perf_data_converter.git /usr/src/perf_data_converter
WORKDIR /usr/src/perf_data_converter

RUN bazel build src:perf_to_profile
RUN cp bazel-bin/src/perf_to_profile /usr/bin/.

FROM golang:latest
# perf_to_profile is dynamically linked against libelf
COPY --from=perf_data_converter /usr/lib/x86_64-linux-gnu/libelf.so /usr/lib/x86_64-linux-gnu/libelf.so
COPY --from=perf_data_converter /usr/bin/perf_to_profile /usr/bin/perf_to_profile
COPY --from=envoy /usr/local/bin/envoy /usr/local/bin/envoy

RUN apt update && apt install -y graphviz
RUN go get -u github.com/google/pprof

ENTRYPOINT ["pprof", "-http=0.0.0.0:8888", "/usr/local/bin/envoy"]
