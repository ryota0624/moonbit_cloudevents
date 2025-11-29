///|
/// CloudEvents Specification JSON Schema
/// Ref: https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/formats/cloudevents.json
pub struct CloudEvents[Data] {
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
  Show,
  Eq,
)

///|
pub fn[Data] CloudEvents::new(
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
) -> CloudEvents[Data] {
  CloudEvents::{
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
  }
}

///|
/// CloudEvents Specification with Extension Fields
pub struct ExtendedCloudEvents[Data, ExtendedFields] {
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
  /// Extension fields
  ///
  /// When serialized to JSON, the fields of this struct will be merged into the top-level CloudEvent JSON object.
  /// They will NOT be nested under an "extended_field" key.
  ///
  /// if you want to use safe ToJson implementation, please implement ToJsonObject trait for ExtendedFields.
  /// otherwise, unsafe ToJson implementation will be used.
  /// 
  extended_field : ExtendedFields
} derive(Show, Eq)

///|
priv struct UnsafeToJsonEnabledExtendedCloudEvent[Data, E](
  ExtendedCloudEvents[Data, E]
)

///|
/// wrapper type that enables unsafe JSON serialization for `ExtendedCloudEvent`
/// instances.
/// This type provides JSON serialization by requiring that the
/// extended fields implement the `ToJson` trait. This allows for more flexibility
/// but may lead to runtime errors if the extended fields do not serialize
/// to JSON objects that can be merged into the top-level CloudEvent JSON structure.
impl[Data : ToJson, E : ToJson] ToJson for UnsafeToJsonEnabledExtendedCloudEvent[
  Data,
  E,
] with to_json(self) -> Json {
  let base = self.0.to_cloud_event().to_json().as_object().unwrap()
  let extended = self.extended_field.to_json().as_object().unwrap()
  Json::object(base.merge(extended))
}

///|
pub fn[Data : ToJson, E : ToJson] ExtendedCloudEvents::unsafe_to_json_enabled(
  self : ExtendedCloudEvents[Data, E],
) -> &ToJson {
  let _ = self.data as &ToJson
  let _ = self.extended_field as &ToJson
  UnsafeToJsonEnabledExtendedCloudEvent(self)
}

///|
/// Wrapper type that enables safe JSON serialization for `ExtendedCloudEvent`
/// instances.
///
/// This type provides type-safe JSON serialization by requiring that the
/// extended fields implement the `ToJsonObject` trait instead of the more
/// general `ToJson` trait. This ensures that extended fields are properly
/// serialized as JSON objects that can be safely merged into the top-level
/// CloudEvent JSON structure.
priv struct SafeToJsonEnabledExtendedCloudEvent[Data, E](
  ExtendedCloudEvents[Data, E]
)

///|
impl[Data : ToJson, E : ToJsonObject] ToJson for SafeToJsonEnabledExtendedCloudEvent[
  Data,
  E,
] with to_json(self) -> Json {
  let base = self.0.to_cloud_event().to_json().as_object().unwrap()
  let extended = self.extended_field.to_json_object()
  Json::object(base.merge(extended))
}

///|
pub fn[Data : ToJson, E : ToJsonObject] ExtendedCloudEvents::safe_to_json_enabled(
  self : ExtendedCloudEvents[Data, E],
) -> &ToJson {
  let _ = self.data as &ToJson
  let _ = self.extended_field as &ToJsonObject
  SafeToJsonEnabledExtendedCloudEvent(self)
}

///|
/// impl constuctor of ExtendedCloudEvent
pub fn[Data, ExtendedFields] ExtendedCloudEvents::new(
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
) -> ExtendedCloudEvents[Data, ExtendedFields] {
  ExtendedCloudEvents::{
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
fn[Data, ExtendedFields] ExtendedCloudEvents::to_cloud_event(
  self : ExtendedCloudEvents[Data, ExtendedFields],
) -> CloudEvents[Data] {
  CloudEvents::{
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
/// Trait for converting extended fields to JSON objects
pub(open) trait ToJsonObject {
  to_json_object(Self) -> Map[String, Json]
}

///|
pub impl[Data : @json.FromJson, E : @json.FromJson] @json.FromJson for ExtendedCloudEvents[
  Data,
  E,
] with from_json(json : Json, json_path : @json.JsonPath) -> ExtendedCloudEvents[
  Data,
  E,
] raise @json.JsonDecodeError {
  let base = CloudEvents::from_json(json, json_path)
  let extended_field = E::from_json(json, json_path)
  ExtendedCloudEvents::{
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
