# Runs the BatchExecutor on the Google Dataflow. It pre-packages dependencies so
# that worker startup is faster and cheaper. It's based on this sample:
# https://github.com/GoogleCloudPlatform/python-docs-samples/blob/main/dataflow/flex-templates/pipeline_with_dependencies/Dockerfile
FROM python:3.11-slim

COPY --from=apache/beam_python3.11_sdk:2.54.0 /opt/apache/beam /opt/apache/beam
COPY --from=gcr.io/dataflow-templates-base/python311-template-launcher-base:20230622_RC00 /opt/google/dataflow/python_template_launcher /opt/google/dataflow/python_template_launcher

WORKDIR /template

ENV FLEX_TEMPLATE_PYTHON_PY_FILE="/template/main.py"

COPY . /template/

RUN pip install --no-cache-dir -r /template/requirements.txt

ENTRYPOINT ["/opt/apache/beam/boot"]