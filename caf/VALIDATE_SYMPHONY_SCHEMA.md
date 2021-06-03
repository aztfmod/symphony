# Validating the Symphony yaml file

## Dependencies

* Install json-spec `sudo pip install json-spec`
* Install yq https://github.com/kislyuk/yq

## Validate Symphony.yml

```bash
json=$(yq '' symphony.yml) && \
json validate \
  --schema-file=symphony.schema.json \
  --document-json="$json"
```

### Schema

To generate a new schema (when symphony.yml updates):

* Execute the following to convert the symphony.yml file to json `yq '' symphony.yml`
* Use a json schema generation tool to generate the schema.For example:
  https://www.liquid-technologies.com/online-json-to-schema-converter