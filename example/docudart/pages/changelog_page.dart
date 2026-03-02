import 'package:docudart/docudart.dart';
import 'package:jaspr/dom.dart';

class ChangelogPage extends StatelessComponent {
  const ChangelogPage({super.key});

  @override
  Component build(BuildContext context) {
    final changelog = context.project.changelog;
    if (changelog == null || changelog.isEmpty) {
      return div(classes: 'docs-content', []);
    }

    final toc = context.project.changelogToc;
    final hasToc = toc != null && toc.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: div(classes: 'docs-content', [RawText(changelog)])),
        if (hasToc) TableOfContents(entries: toc),
        TocScrollSpy(),
      ],
    );
  }
}
