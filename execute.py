from typing import Iterator

import apache_beam as beam
import structlog
from apache_beam.pvalue import PCollection

log = structlog.stdlib.get_logger()


class Execute(beam.PTransform):
    def expand(self, pcollection: PCollection[str]) -> PCollection[str]:
        return pcollection | "Execute" >> beam.ParDo(ExecuteFn())


class ExecuteFn(beam.DoFn):
    def __init__(self):
        self._lines: list[str] = []

    def process(self, element: str) -> Iterator[str]:
        self._lines.append(element)
        yield element

    def start_bundle(self) -> None:
        log.error("Starting bundle")
        self._lines = []

    def finish_bundle(self) -> None:
        log.error(f"Finishing bundle, outputting {len(self._lines)} lines")
        for line in self._lines:
            log.error(f"Outputting line: {line}")
