import 'package:docudart/docudart.dart';

class ChangelogPage extends StatelessComponent {
  const ChangelogPage({super.key});

  @override
  Component build(BuildContext context) {
    final changelog = context.project.changelog;
    if (changelog == null || changelog.isEmpty) {
      return div(classes: 'docs-content', []);
    }
    return div(classes: 'docs-content', [RawText(changelog)]);
  }
}
