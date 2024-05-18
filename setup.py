import setuptools

# Dataflow expects pipelines to be a single file, but we use code split into
# multiple files. To work around this, we add __init__.py files to folders so
# that they are treated as packages and then found by the code below.

setuptools.setup(
    name="dataflow",
    version="0.0.0",
    packages=setuptools.find_packages(),
)
