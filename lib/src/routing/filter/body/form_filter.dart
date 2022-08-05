part of minerva_routing;

enum FormFieldType { string, file }

class FormField {
  final String name;

  final FormFieldType? type;

  FormField(this.name, this.type);
}

class FormFilter extends BodyFilter {
  final List<FormField> fields;

  FormFilter(this.fields);
}
