import 'package:docudart/docudart.dart';

class ChangelogPage extends StatelessComponent {
  const ChangelogPage({super.key});

  @override
  Component build(BuildContext context) {
    return Markdown(content: context.project.changelog ?? '');
  }
}
