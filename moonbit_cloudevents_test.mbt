///|
priv struct AuditLogExtension {
  methodName : String
  resourceName : String
  serviceName : String
} derive(FromJson)

///|
impl @moonbit_cloudevents.ToJsonObject for AuditLogExtension with to_json_object(
  self,
) -> Map[String, Json] {
  {
    "methodName": Json::string(self.methodName),
    "resourceName": Json::string(self.resourceName),
    "serviceName": Json::string(self.serviceName),
  }
}

///|
priv struct ApplicationLogExtension {
  methodName : String
  resourceName : String
  serviceName : String
} derive(ToJson)

///|
test "ExtendedCloudEvent fromJson" {
  let json_string =
    #|{
    #| "data":{},
    #| "datacontenttype": "application/json; charset=utf-8",
    #| "id": "MESSAGE_ID",
    #| "source": "//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
    #| "specversion": "1.0",
    #| "type": "google.cloud.audit.log.v1.written",
    #| "time": "EVENT_GENERATION_TIME",
    #| "dataschema": "https://googleapis.github.io/google-cloudevents/jsonschema/google/events/cloud/audit/v1/LogEntryData.json",
    #| "methodName": "jobservice.jobcompleted",
    #| "resourceName": "projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
    #| "serviceName": "bigquery.googleapis.com",
    #| "subject": "bigquery.googleapis.com/projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1"
    #| }
  let cloud_event : ExtendedCloudEvents[Json, AuditLogExtension] = @json.from_json(
    @json.parse(json_string),
  )
  inspect(cloud_event.id, content="MESSAGE_ID")
  inspect(
    cloud_event.source,
    content="//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
  )
  inspect(cloud_event.specversion, content="1.0")
  inspect(cloud_event.type_, content="google.cloud.audit.log.v1.written")
  inspect(cloud_event.time.unwrap(), content="EVENT_GENERATION_TIME")
  inspect(
    cloud_event.dataschema.unwrap(),
    content="https://googleapis.github.io/google-cloudevents/jsonschema/google/events/cloud/audit/v1/LogEntryData.json",
  )
  inspect(
    cloud_event.subject.unwrap(),
    content="bigquery.googleapis.com/projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
  )
  inspect(
    cloud_event.extended_field.methodName,
    content="jobservice.jobcompleted",
  )
  inspect(
    cloud_event.extended_field.resourceName,
    content="projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
  )
  inspect(
    cloud_event.extended_field.serviceName,
    content="bigquery.googleapis.com",
  )
}

///|
test "ExtendedCloudEvent toJson safe" {
  let cloud_event = @moonbit_cloudevents.ExtendedCloudEvents::new(
    id="MESSAGE_ID",
    source="//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
    specversion="1.0",
    type_="google.cloud.audit.log.v1.written",
    datacontenttype=Some("application/json; charset=utf-8"),
    dataschema=Some(
      "https://googleapis.github.io/google-cloudevents/jsonschema/google/events/cloud/audit/v1/LogEntryData.json",
    ),
    subject=Some(
      "bigquery.googleapis.com/projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
    ),
    time=Some("EVENT_GENERATION_TIME"),
    data=Json::null(),
    data_base64=None,
    extended_field=AuditLogExtension::{
      methodName: "jobservice.jobcompleted",
      resourceName: "projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
      serviceName: "bigquery.googleapis.com",
    },
  )
  inspect(
    cloud_event.safe_to_json_enabled().to_json().stringify(indent=1),
    content=(
      #|{
      #| "id": "MESSAGE_ID",
      #| "source": "//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
      #| "specversion": "1.0",
      #| "type": "google.cloud.audit.log.v1.written",
      #| "datacontenttype": "application/json; charset=utf-8",
      #| "dataschema": "https://googleapis.github.io/google-cloudevents/jsonschema/google/events/cloud/audit/v1/LogEntryData.json",
      #| "subject": "bigquery.googleapis.com/projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
      #| "time": "EVENT_GENERATION_TIME",
      #| "data": null,
      #| "methodName": "jobservice.jobcompleted",
      #| "resourceName": "projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
      #| "serviceName": "bigquery.googleapis.com"
      #|}
    ),
  )
}

///|
test "ExtendedCloudEvent toJson unsafe" {
  let cloud_event = @moonbit_cloudevents.ExtendedCloudEvents::new(
    id="MESSAGE_ID",
    source="//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
    specversion="1.0",
    type_="google.cloud.audit.log.v1.written",
    datacontenttype=Some("application/json; charset=utf-8"),
    dataschema=Some(
      "https://googleapis.github.io/google-cloudevents/jsonschema/google/events/cloud/audit/v1/LogEntryData.json",
    ),
    subject=Some(
      "bigquery.googleapis.com/projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
    ),
    time=Some("EVENT_GENERATION_TIME"),
    data=Json::null(),
    data_base64=None,
    extended_field=ApplicationLogExtension::{
      methodName: "jobservice.jobcompleted",
      resourceName: "projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
      serviceName: "bigquery.googleapis.com",
    },
  )
  inspect(
    cloud_event.unsafe_to_json_enabled().to_json().stringify(indent=1),
    content=(
      #|{
      #| "id": "MESSAGE_ID",
      #| "source": "//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
      #| "specversion": "1.0",
      #| "type": "google.cloud.audit.log.v1.written",
      #| "datacontenttype": "application/json; charset=utf-8",
      #| "dataschema": "https://googleapis.github.io/google-cloudevents/jsonschema/google/events/cloud/audit/v1/LogEntryData.json",
      #| "subject": "bigquery.googleapis.com/projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
      #| "time": "EVENT_GENERATION_TIME",
      #| "data": null,
      #| "methodName": "jobservice.jobcompleted",
      #| "resourceName": "projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
      #| "serviceName": "bigquery.googleapis.com"
      #|}
    ),
  )
}

///|
test {
  let json_string =
    #|{
    #| "id": "MESSAGE_ID",
    #| "source": "//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
    #| "specversion": "1.0",
    #| "type": "google.cloud.audit.log.v1.written",
    #| "datacontenttype": "application/json; charset=utf-8",
    #| "dataschema": "https://googleapis.github.io/google-cloudevents/jsonschema/google/events/cloud/audit/v1/LogEntryData.json",
    #| "subject": "bigquery.googleapis.com/projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
    #| "time": "EVENT_GENERATION_TIME",
    #| "data": {}
    #|}
  let cloud_event : CloudEvents[Json] = @json.from_json(@json.parse(json_string))
  inspect(cloud_event.id, content="MESSAGE_ID")
  inspect(
    cloud_event.source,
    content="//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
  )
  inspect(cloud_event.specversion, content="1.0")
  inspect(cloud_event.type_, content="google.cloud.audit.log.v1.written")
  inspect(cloud_event.time.unwrap(), content="EVENT_GENERATION_TIME")
  inspect(
    cloud_event.dataschema.unwrap(),
    content="https://googleapis.github.io/google-cloudevents/jsonschema/google/events/cloud/audit/v1/LogEntryData.json",
  )
  inspect(
    cloud_event.subject.unwrap(),
    content="bigquery.googleapis.com/projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
  )
  inspect(cloud_event.to_json().stringify(indent=1), content=json_string)
}
