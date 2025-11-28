///|
/// CloudEvents Specification JSON Schema
/// Ref: https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/formats/cloudevents.json
pub struct CloudEvent[Data] {
  /// Identifies the event.
  id : String
  /// Identifies the context in which an event happened.
  source : String
  /// The version of the CloudEvents specification which the event uses.
  specversion : String
  /// Describes the type of event related to the originating occurrence.
  type_ : String
  /// Content type of the data value. Must adhere to RFC 2046 format.
  datacontenttype : String?
  /// Identifies the schema that data adheres to.
  dataschema : String?
  /// Describes the subject of the event in the context of the event producer (identified by source).
  subject : String?
  /// Timestamp of when the occurrence happened. Must adhere to RFC 3339.
  time : String?
  /// The event payload.
  data : Data
  /// Base64 encoded event payload. Must adhere to RFC4648.
  data_base64 : String?
} derive (
  FromJson(fields(type_(rename="type"))),
  ToJson(fields(type_(rename="type"))),
)

///|
pub struct ExtendedCloudEvent[Data, ExtendedFields] {
  /// Identifies the event.
  id : String
  /// Identifies the context in which an event happened.
  source : String
  /// The version of the CloudEvents specification which the event uses.
  specversion : String
  /// Describes the type of event related to the originating occurrence.
  type_ : String
  /// Content type of the data value. Must adhere to RFC 2046 format.
  datacontenttype : String?
  /// Identifies the schema that data adheres to.
  dataschema : String?
  /// Describes the subject of the event in the context of the event producer (identified by source).
  subject : String?
  /// Timestamp of when the occurrence happened. Must adhere to RFC 3339.
  time : String?
  /// The event payload.
  data : Data
  /// Base64 encoded event payload. Must adhere to RFC4648.
  data_base64 : String?
  extended_field : ExtendedFields
}

///|
/// impl constuctor of ExtendedCloudEvent
pub fn[Data, ExtendedFields] ExtendedCloudEvent::new(
  id~ : String,
  source~ : String,
  specversion~ : String,
  type_~ : String,
  datacontenttype? : String? = None,
  dataschema? : String? = None,
  subject? : String? = None,
  time? : String? = None,
  data~ : Data,
  data_base64? : String? = None,
  extended_field~ : ExtendedFields,
) -> ExtendedCloudEvent[Data, ExtendedFields] {
  ExtendedCloudEvent::{
    id,
    source,
    specversion,
    type_,
    datacontenttype,
    dataschema,
    subject,
    time,
    data,
    data_base64,
    extended_field,
  }
}

///|
pub fn[Data, ExtendedFields] ExtendedCloudEvent::to_cloud_event(
  self : ExtendedCloudEvent[Data, ExtendedFields],
) -> CloudEvent[Data] {
  CloudEvent::{
    id: self.id,
    source: self.source,
    specversion: self.specversion,
    type_: self.type_,
    datacontenttype: self.datacontenttype,
    dataschema: self.dataschema,
    subject: self.subject,
    time: self.time,
    data: self.data,
    data_base64: self.data_base64,
  }
}

///|
pub trait ToJsonObject {
  to_json_object(Self) -> Map[String, Json]
}

///|
pub impl ToJson for &ToJsonObject with to_json(self) -> Json {
  Json::object(self.to_json_object())
}

///|
pub impl[Data : ToJson, E : ToJsonObject] ToJson for ExtendedCloudEvent[Data, E] with to_json(
  self,
) -> Json {
  let base = self.to_cloud_event().to_json().as_object().unwrap()
  let extended = self.extended_field.to_json_object()
  Json::object(base.merge(extended))
}

///|
pub impl[Data : @json.FromJson, E : @json.FromJson] @json.FromJson for ExtendedCloudEvent[
  Data,
  E,
] with from_json(json : Json, json_path : @json.JsonPath) -> ExtendedCloudEvent[
  Data,
  E,
] raise @json.JsonDecodeError {
  let base = CloudEvent::from_json(json, json_path)
  let extended_field = E::from_json(json, json_path)
  ExtendedCloudEvent::{
    id: base.id,
    source: base.source,
    specversion: base.specversion,
    type_: base.type_,
    datacontenttype: base.datacontenttype,
    dataschema: base.dataschema,
    subject: base.subject,
    time: base.time,
    data: base.data,
    data_base64: base.data_base64,
    extended_field,
  }
}

///|
priv struct AuditLogExtension {
  methodName : String
  resourceName : String
  serviceName : String
} derive(FromJson)

///|
impl ToJsonObject for AuditLogExtension with to_json_object(self) -> Map[
  String,
  Json,
] {
  {
    "methodName": Json::string(self.methodName),
    "resourceName": Json::string(self.resourceName),
    "serviceName": Json::string(self.serviceName),
  }
}

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
  let cloud_event : ExtendedCloudEvent[Json, AuditLogExtension] = @json.from_json(
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
test "ExtendedCloudEvent toJson" {
  let cloud_event = ExtendedCloudEvent::{
    id: "MESSAGE_ID",
    source: "//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
    specversion: "1.0",
    type_: "google.cloud.audit.log.v1.written",
    datacontenttype: Some("application/json; charset=utf-8"),
    dataschema: Some(
      "https://googleapis.github.io/google-cloudevents/jsonschema/google/events/cloud/audit/v1/LogEntryData.json",
    ),
    subject: Some(
      "bigquery.googleapis.com/projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
    ),
    time: Some("EVENT_GENERATION_TIME"),
    data: Json::null(),
    data_base64: None,
    extended_field: AuditLogExtension::{
      methodName: "jobservice.jobcompleted",
      resourceName: "projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
      serviceName: "bigquery.googleapis.com",
    },
  }
  inspect(
    cloud_event.to_json().stringify(indent=1),
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
  let cloud_event : CloudEvent[Json] = @json.from_json(@json.parse(json_string))
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
