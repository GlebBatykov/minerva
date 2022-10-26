part of minerva_routing;

enum FormFieldType { string, file }

/// Used when filtering requests, to check for the presence of form field in the form data request body.
class FormField {
  ///
  final String name;

  ///
  final FormFieldType? type;

  const FormField(this.name, this.type);
}

/// The body filter is used to filter out requests that do not match it.
class FormFilter extends BodyFilter {
  /// Form fields that the request should contain.
  final List<FormField> fields;

  const FormFilter({required this.fields});
}
