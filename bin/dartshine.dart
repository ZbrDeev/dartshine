import 'create_project.dart';

Future<void> main(List<String> args) async {
  if (args[0] == 'create' && args.length == 2) {
    await createProject(args[1]);
  } else if (args[0] == 'version') {
    print("Dartshine 2.3.8");
  }
}
