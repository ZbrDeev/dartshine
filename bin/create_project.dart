import 'dart:io';
import 'package:dartshine/src/error/folder_error.dart';
import 'package:path/path.dart' as p;
import 'dart:isolate';

Future<String> readFile(String path) async {
  var resolvedUri =
      await Isolate.resolvePackageUri(Uri.parse('package:dartshine/$path'));
  var filePath = p.fromUri(resolvedUri);
  var file = File(filePath);
  return await file.readAsString();
}

Future<void> createProject(String name) async {
  String currentPath = Directory.current.path;
  String projectPath = p.join(currentPath, name);
  Directory newProjectDir = Directory(projectPath);

  if (await newProjectDir.exists()) {
    throw FolderError(folder: newProjectDir.path);
  }

  await newProjectDir.create();

  await Directory(p.join(projectPath, 'lib')).create();
  await Directory(p.join(projectPath, 'bin')).create();
  await Directory(p.join(projectPath, 'lib/routes')).create();
  await Directory(p.join(projectPath, 'lib/controllers')).create();
  await Directory(p.join(projectPath, 'lib/orm')).create();
  await Directory(p.join(projectPath, 'lib/middleware')).create();
  await Directory(p.join(projectPath, 'assets')).create();

  String indexFileContent = await readFile('init/assets/index.html');
  String styleFileContent = await readFile('init/assets/style.css');
  String controllerFileContent = await readFile('init/root_controller');
  String routesFileContent = await readFile('init/routes');
  String mainFileContent = await readFile('init/main');
  String pubspecFileContent = await readFile('init/pubspec');
  String analysisFileContent = await readFile('init/analysis_options');
  String userFileContent = await readFile('init/user');
  String ormsFileContent = await readFile('init/orms');
  String binFileContent = await readFile('init/bin');
  String middlewareFileContent = await readFile('init/middleware');
  String middlewareLoggerFileContent = await readFile('init/logger');

  controllerFileContent = controllerFileContent.replaceFirst('{}', name);
  binFileContent = binFileContent.replaceAll('{}', name);
  routesFileContent = routesFileContent.replaceAll('{}', name);
  ormsFileContent = ormsFileContent.replaceAll('{}', name);
  mainFileContent = mainFileContent.replaceAll('{}', name);
  pubspecFileContent = pubspecFileContent.replaceAll('{}', name);
  middlewareFileContent = middlewareFileContent.replaceAll('{}', name);

  File indexFile = File(p.join(projectPath, 'assets/index.html'));
  File mainFile = File(p.join(projectPath, 'lib/$name.dart'));
  File binFile = File(p.join(projectPath, 'bin/$name.dart'));
  File controllerFile =
      File(p.join(projectPath, 'lib/controllers/root_controller.dart'));
  File routesFile = File(p.join(projectPath, 'lib/routes/routes.dart'));
  File pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
  File analysisFile = File(p.join(projectPath, 'analysis_options.yaml'));
  File userFile = File(p.join(projectPath, 'lib/orm/user.dart'));
  File ormsFile = File(p.join(projectPath, 'lib/orm/orms.dart'));
  File middlewareFile =
      File(p.join(projectPath, 'lib/middleware/middleware.dart'));
  File middlewareLoggerFile =
      File(p.join(projectPath, 'lib/middleware/logger.dart'));
  File styleFile = File(p.join(projectPath, 'assets/style.css'));

  await indexFile.create();
  await styleFile.create();
  await mainFile.create();
  await binFile.create();
  await controllerFile.create();
  await routesFile.create();
  await pubspecFile.create();
  await analysisFile.create();
  await userFile.create();
  await ormsFile.create();
  await middlewareFile.create();
  await middlewareLoggerFile.create();

  await indexFile.writeAsString(indexFileContent);
  await styleFile.writeAsString(styleFileContent);
  await mainFile.writeAsString(mainFileContent);
  await binFile.writeAsString(binFileContent);
  await controllerFile.writeAsString(controllerFileContent);
  await routesFile.writeAsString(routesFileContent);
  await pubspecFile.writeAsString(pubspecFileContent);
  await analysisFile.writeAsString(analysisFileContent);
  await userFile.writeAsString(userFileContent);
  await ormsFile.writeAsString(ormsFileContent);
  await middlewareFile.writeAsString(middlewareFileContent);
  await middlewareLoggerFile.writeAsString(middlewareLoggerFileContent);
}
