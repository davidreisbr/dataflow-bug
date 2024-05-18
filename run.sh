# Runs the dataflow job end to end, reading and writing data to GCS.
set -e

# Change these params.
project_id=vomdecision
bucket=8c38km-dev

tag=$USER
echo "Using tag : $tag"

script_dir=$(dirname "$0")
cd $script_dir

echo Starting deployment...

temp_dir=$(mktemp -d)
echo "Temporary deploy dir created at: $temp_dir"
cp -r * $temp_dir/

poetry export -f requirements.txt --output $temp_dir/requirements.txt \
  --without-urls --without-hashes

cd $temp_dir
gcloud builds submit --config=cloudbuild.yaml \
  --substitutions=TAG_NAME=$tag,_BUCKET="$bucket"

gcloud dataflow flex-template build \
  gs://$bucket/temp/$tag.json \
  --image="gcr.io/vomdecision/$bucket/dataflow:$tag" \
  --sdk-language=PYTHON \
  --metadata-file=metadata.json

temp_file=$(mktemp)
cat << EOF > "$temp_file"
line1
line2
line3
EOF

filename="${tag}_$(date +"%Y_%m_%d_%Hh_%Mm")"
input_file="gs://$bucket/temp/$filename"
output_file="gs://$bucket/temp/$filename.out"
echo "Uploading test file to $input_file..."
cat "$temp_file"

gsutil cp "$temp_file" "$input_file"
echo

echo "Running the job on dataflow..."
gcloud dataflow flex-template run "${tag}-dataflow" \
  --region=us-east1 \
  --template-file-gcs-location="gs://$bucket/temp/$tag.json" \
  --parameters="input_file=$input_file" \
  --parameters="output_file=$output_file" \
  --parameters="sdk_container_image=gcr.io/vomdecision/$bucket/dataflow:$tag"