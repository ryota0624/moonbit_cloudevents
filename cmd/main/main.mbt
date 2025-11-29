///|
fn main {
  try {
    let cloud_events = @lib.CloudEvents::new(
      id="1234",
      source="unit/test",
      specversion="1.0",
      type_="com.example.test",
      data=Json::object({ "message": "Hello, CloudEvents!" }),
    )
    println(cloud_events)
    let json = cloud_events.to_json()
    println("Serialized CloudEvents to JSON:")
    println(json.stringify(indent=2))
    let deserialized_event : @lib.CloudEvents[Json] = @json.from_json(json)
    println("Deserialized CloudEvents from JSON:")
    println(deserialized_event)
  } catch {
    _ => println("An error occurred during CloudEvents processing.")
  }
  try {
    let extended_event = @lib.ExtendedCloudEvents::new(
      id="5678",
      source="unit/test/extended",
      specversion="1.0",
      type_="com.example.extended",
      data=Json::object({ "info": "Extended CloudEvents!" }),
      extended_field=AuditLogExtension::{
        methodName: "test.method",
        resourceName: "projects/test/resources/1",
        serviceName: "test.service",
      },
    )
    println(extended_event)
    let json_ext = extended_event.unsafe_to_json_enabled().to_json()
    println("Serialized ExtendedCloudEvents to JSON:")
    println(json_ext.stringify(indent=2))
    let deserialized_ext_event : @lib.ExtendedCloudEvents[
      Json,
      AuditLogExtension,
    ] = @json.from_json(json_ext)
    println("Deserialized ExtendedCloudEvents from JSON:")
    println(deserialized_ext_event)
  } catch {
    _ => println("An error occurred during ExtendedCloudEvents processing.")
  }
}

///|
struct AuditLogExtension {
  methodName : String
  resourceName : String
  serviceName : String
} derive(FromJson, ToJson, Show, Eq)
