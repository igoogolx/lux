import 'package:background_downloader/background_downloader.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../tr.dart';

class AutoUpdaterDialogContent extends StatefulWidget {
  final Transfer downloadTransfer;

  const AutoUpdaterDialogContent(this.downloadTransfer, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AutoUpdaterDialogContentState();
  }
}

class _AutoUpdaterDialogContentState extends State<AutoUpdaterDialogContent> {
  bool isDownloadComplete = false;
  double? downloadProgress = 0;

  Future<String> _getFilePath() async {
    final filePath = await widget.downloadTransfer.task.filePath();

    return filePath;
  }

  void _handleOpenDir() async {
    final filePath = await _getFilePath();

    final dir = p.dirname(filePath);

    launchUrl(Uri.file(dir));
  }

  void _handleUpgrade() async {
    final filePath = await _getFilePath();

    launchUrl(Uri.file(filePath));
  }

  @override
  void initState() {
    super.initState();

    widget.downloadTransfer.progressNotifier.addListener(() {
      setState(() {
        downloadProgress = widget.downloadTransfer.progress;
        debugPrint("$downloadProgress");
      });
    });

    widget.downloadTransfer.statusNotifier.addListener(() {
      if (widget.downloadTransfer.status == TaskStatus.complete) {
        setState(() {
          isDownloadComplete = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.downloadTransfer.task.displayName.isNotEmpty
        ? widget.downloadTransfer.task.displayName
        : widget.downloadTransfer.task.filename;

    final theme = Theme.of(context);

    return Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(children: [
          Row(
            children: [
              Text(
                tr().autoUpdaterDialogTitle,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              )
            ],
          ),
          Container(
            padding: EdgeInsetsGeometry.fromLTRB(0, 32, 0, 16),
            child: Card(
              child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: Icon(Icons.download, size: 20),
                  ),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: TransferProgressBar(
                      transfer: widget.downloadTransfer,
                      showSpeed: true,
                      showPercentage: true,
                    ),
                  )),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: isDownloadComplete ? _handleOpenDir : null,
                  child: Text(tr().open)),
              TextButton(
                  onPressed: isDownloadComplete ? _handleUpgrade : null,
                  child: Text(tr().upgrade))
            ],
          )
        ]));
  }
}
