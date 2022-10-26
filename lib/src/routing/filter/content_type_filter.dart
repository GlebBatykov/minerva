part of minerva_routing;

/// The content-type filter is used to filter out requests that do not match it.
class ContentTypeFilter {
  /// Accepted content types.
  final List<String> accepts;

  const ContentTypeFilter(this.accepts);
}
