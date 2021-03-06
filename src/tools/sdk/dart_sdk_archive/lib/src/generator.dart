import 'package:dart_sdk_archive/src/util.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/async.dart' as quiver_async;
import 'package:sdk_builds/sdk_builds.dart';

class SvnVersionGenerator {
  final _downloader = DartDownloads();

  Future<Map<String, String>> get svnVersions async {
    var versionInfos = <String, VersionInfo>{};
    await Future.wait([
      _loadVersionInfo(versionInfos, 'stable'),
      _loadVersionInfo(versionInfos, 'beta'),
      _loadVersionInfo(versionInfos, 'dev'),
    ]);
    var result = <String, String>{};
    versionInfos.forEach((revision, version) {
      result[revision] = version.toString();
    });
    return result;
  }

  Future _loadVersionInfo(
      Map<String, VersionInfo> versionInfos, String channel) async {
    var versionPaths = await _downloader.fetchVersionPaths(channel);
    var versionBaseNames =
        await versionPaths.map((s) => path.basename(s)).toList();

    await quiver_async.forEachAsync(versionBaseNames, (name) async {
      if (!isSvnRevision(name)) {
        return;
      }

      var versionInfo = await _downloader.fetchVersion(channel, name);
      versionInfos[name] = versionInfo;
    }, maxTasks: 6);
  }
}
