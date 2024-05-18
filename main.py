import structlog
import structlog_gcp
from apache_beam.io import ReadFromText, WriteToText
from apache_beam.options.pipeline_options import GoogleCloudOptions, PipelineOptions
from apache_beam.pipeline import Pipeline
from execute import Execute

structlog.configure(processors=structlog_gcp.build_processors())
log = structlog.stdlib.get_logger()


class CustomOptions(PipelineOptions):  # pylint: disable=too-few-public-methods
    @classmethod
    def _add_argparse_args(cls, parser) -> None:
        parser.add_argument("--input_file", type=str)
        parser.add_argument("--output_file", type=str)


def run() -> None:
    options = CustomOptions()

    google_cloud_options = options.view_as(GoogleCloudOptions)
    google_cloud_options.region = "us-east1"

    with Pipeline(options=options) as pipeline:
        _ = (
            pipeline
            | "Read input file" >> ReadFromText(options.input_file)
            | "Execute" >> Execute()
            | "Write CSV File" >> WriteToText(options.output_file)
        )


if __name__ == "__main__":
    run()
