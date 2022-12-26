part of minerva_routing;

/// Form field types.
///
/// Used when filtering requests, to check for the presence of form field in the request body.
enum FormFieldType { string, file }

/// Used when filtering requests, to check for the presence of form field in the request body.
class FormField {
  /// Name of form field.
  final String name;

  /// Type of form field.
  final FormFieldType? type;

  const FormField({required this.name, this.type});
}

/// The body filter is used to filter out requests that do not match it.
class FormFilter extends BodyFilter {
  /// Form fields that the request should contain.
  final List<FormField> fields;

  const FormFilter({required this.fields});
}
