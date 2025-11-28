///|
struct T[Data, E](@moonbit_cloudevents.ExtendedCloudEvent[Data, E])

///|
pub impl[Data : ToJson, E : ToJson] ToJson for T[Data, E] with to_json(self) -> Json {
  let base = self.0.to_cloud_event().to_json().as_object().unwrap()
  let extended = self.extended_field.to_json().as_object().unwrap()
  Json::object(base.merge(extended))
}

///|
pub impl[Data : @json.FromJson, E : @json.FromJson] @json.FromJson for T[
  Data,
  E,
] with from_json(json : Json, json_path : @json.JsonPath) -> T[Data, E] raise @json.JsonDecodeError {
  let events = @json.from_json(json, path=json_path)
  T(events)
}

///|
priv struct AuditLogExtension {
  methodName : String
  resourceName : String
  serviceName : String
} derive(FromJson, ToJson)

///|
test "ExtendedCloudEvent toJson" {
  let cloud_event : @moonbit_cloudevents.ExtendedCloudEvent[
    Json,
    AuditLogExtension,
  ] = @moonbit_cloudevents.ExtendedCloudEvent::new(
    id="MESSAGE_ID",
    source="//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
    specversion="1.0",
    type_="google.cloud.audit.log.v1.written",
    datacontenttype=Some("application/json; charset=utf-8"),
    data=Json::null(),
    extended_field=AuditLogExtension::{
      methodName: "jobservice.jobcompleted",
      resourceName: "projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
      serviceName: "bigquery.googleapis.com",
    },
  )
  inspect(
    T(cloud_event).to_json().stringify(indent=1),
    content=(
      #|{
      #| "id": "MESSAGE_ID",
      #| "source": "//cloudaudit.googleapis.com/projects/PROJECT_ID/logs/data_access",
      #| "specversion": "1.0",
      #| "type": "google.cloud.audit.log.v1.written",
      #| "datacontenttype": "application/json; charset=utf-8",
      #| "data": null,
      #| "methodName": "jobservice.jobcompleted",
      #| "resourceName": "projects/my-project/jobs/bqjob_r3ac45813612fa2d6_0000017d591922c9_1",
      #| "serviceName": "bigquery.googleapis.com"
      #|}
    ),
  )
}
