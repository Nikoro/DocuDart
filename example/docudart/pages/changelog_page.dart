import 'package:docudart/docudart.dart';

class ChangelogPage extends StatelessComponent {
  const ChangelogPage({super.key});

  @override
  Component build(BuildContext context) {
    final changelog = context.project.changelog;
    if (changelog == null) {
      return div(classes: 'docs-content', []);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: div(classes: 'docs-content', [RawText(changelog.raw)])),
        if (changelog.toc.isNotEmpty)
          TableOfContents(entries: changelog.toc, basePath: '/changelog/'),
        TocScrollSpy(),
      ],
    );
  }
}
