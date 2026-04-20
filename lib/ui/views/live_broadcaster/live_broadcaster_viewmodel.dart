import 'package:stacked/stacked.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:haishin_kit/haishin_kit.dart';
import '../../../../app/app.locator.dart';
import '../../../../services/srs_streaming_service.dart';

class LiveBroadcasterViewModel extends BaseViewModel {
  final _srsService = locator<SrsStreamingService>();
  
  RtmpConnection? rtmpConnection;
  RtmpStream? rtmpStream;
  
  bool isCameraInitialized = false;
  bool isStreaming = false;
  
  String streamKey = "demo_stream"; 

  // UI state
  int viewerCount = 0;

  void initBroadcaster() async {
    setBusy(true);

    // Demande des permissions Caméra et Micro
    var cameraStatus = await Permission.camera.request();
    var micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await _initHaishinKit();
    } else {
      print("Permissions refusées");
      // TODO: Gérer le refus des permissions
    }

    setBusy(false);
  }

  Future<void> _initHaishinKit() async {
    rtmpConnection = await RtmpConnection.create();
    rtmpConnection?.addEventListener("rtmpStatus", (event) {
      final data = event.data as Map;
      if (data["code"] == "NetConnection.Connect.Success") {
        print("Connected to SRS!");
        isStreaming = true;
        notifyListeners();
      } else if (data["code"] == "NetConnection.Connect.Closed") {
        print("Disconnected from SRS.");
        isStreaming = false;
        notifyListeners();
      }
    });

    rtmpStream = await RtmpStream.create(rtmpConnection!);
    
    // Configurer l'audio et la vidéo (Qualité et Ratio 9:16)
    await rtmpStream?.updateAudioZIndex(0);
    await rtmpStream?.updateVideoZIndex(1);
    
    // Attacher la caméra et le micro
    await rtmpStream?.attachAudio(AudioSource());
    await rtmpStream?.attachVideo(VideoSource(position: CameraPosition.front));

    isCameraInitialized = true;
    notifyListeners();
  }

  void toggleLiveStream() {
    if (isStreaming) {
      rtmpConnection?.close();
      isStreaming = false;
    } else {
      // Démarrage du flux RTMP vers le serveur
      String pushUrl = _srsService.getRtmpPushUrl(streamKey);
      
      // La fonction connect s'attend à l'URL de base et la clé de flux
      // L'URL Push est séparée par ex: rtmp://url/live et 'stream_key'
      int lastSlash = pushUrl.lastIndexOf('/');
      String serverUrl = pushUrl.substring(0, lastSlash);
      String key = pushUrl.substring(lastSlash + 1);

      rtmpConnection?.connect(serverUrl);
      rtmpStream?.publish(key);
    }
    notifyListeners();
  }
  
  void switchCamera() async {
    // Logique pour changer de caméra via Haishinkit si nécessaire
  }

  @override
  void dispose() {
    rtmpStream?.dispose();
    rtmpConnection?.dispose();
    super.dispose();
  }
}
