import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:promogoai/app/app.locator.dart';

/// Service abstrait permettant de changer facilement de moteur WebRTC (Agora, LiveKit, etc.)
abstract class LiveStreamingService {
  Future<void> initialize();
  Future<void> joinChannelAsBroadcaster(String channelId, {String? token});
  Future<void> joinChannelAsViewer(String channelId, {String? token});
  Future<void> leaveChannel();
  Future<void> startLocalPreview();
  Future<void> stopLocalPreview();
  Future<void> switchCamera();
  Future<void> toggleMute(bool isMuted);
  Future<void> dispose();
  
  int? get currentRemoteUid;
  void setRemoteUserCallback(Function(int?) callback);
  
  // Widget pour afficher la vidéo locale ou distante
  Widget buildVideoView({int? remoteUid, required String channelId, bool isBroadcaster = false});
}

/// Implémentation spécifique pour Agora
class AgoraStreamingService implements LiveStreamingService {
  late RtcEngine _engine;
  String get _appId => dotenv.env['AGORA_APP_ID'] ?? 'VOTRE_APP_ID_AGORA'; 

  bool _isInitialized = false;
  // Callbacks
  Function(int?)? onRemoteUserChanged;
  final _snackbarService = locator<SnackbarService>();
  
  int? _currentRemoteUid;
  
  @override
  int? get currentRemoteUid => _currentRemoteUid;

  @override
  void setRemoteUserCallback(Function(int?) callback) {
    onRemoteUserChanged = callback;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: _appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("✅ [Agora] Rejoint le canal: ${connection.channelId}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("👤 [Agora] Utilisateur distant a rejoint: $remoteUid");
          _currentRemoteUid = remoteUid;
          onRemoteUserChanged?.call(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("👤 [Agora] Utilisateur distant a quitté: $remoteUid");
          if (_currentRemoteUid == remoteUid) {
            _currentRemoteUid = null;
            onRemoteUserChanged?.call(null);
          }
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint("❌ [Agora] Erreur: $err, $msg");
          _snackbarService.showSnackbar(
            title: "Erreur Agora",
            message: "$err: $msg",
            duration: const Duration(seconds: 5),
          );
        },
      ),
    );

    _isInitialized = true;
  }

  @override
  Future<void> startLocalPreview() async {
    if (!_isInitialized) await initialize();
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
  }

  @override
  Future<void> stopLocalPreview() async {
    if (!_isInitialized) return;
    await _engine.stopPreview();
  }

  @override
  Future<void> joinChannelAsBroadcaster(String channelId, {String? token}) async {
    if (!_isInitialized) await initialize();

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    // La preview est gérée manuellement, on peut la laisser

    String finalToken = token ?? dotenv.env['AGORA_TEMP_TOKEN'] ?? '';

    await _engine.joinChannel(
      token: finalToken,
      channelId: channelId,
      uid: 0, // 0 = Agora assigne un UID automatiquement
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  @override
  Future<void> joinChannelAsViewer(String channelId, {String? token}) async {
    if (!_isInitialized) await initialize();

    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine.enableVideo();

    String finalToken = token ?? dotenv.env['AGORA_TEMP_TOKEN'] ?? '';

    await _engine.joinChannel(
      token: finalToken, 
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  @override
  Future<void> leaveChannel() async {
    if (!_isInitialized) return;
    await _engine.stopPreview();
    await _engine.leaveChannel();
  }

  @override
  Future<void> switchCamera() async {
    if (!_isInitialized) return;
    await _engine.switchCamera();
  }

  @override
  Future<void> toggleMute(bool isMuted) async {
    if (!_isInitialized) return;
    await _engine.muteLocalAudioStream(isMuted);
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;
    await _engine.leaveChannel();
    await _engine.release();
    _isInitialized = false;
  }

  @override
  Widget buildVideoView({int? remoteUid, required String channelId, bool isBroadcaster = false}) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isBroadcaster) {
      // Broadcaster (Local)
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
          useAndroidSurfaceView: true,
        ),
      );
    } else {
      if (remoteUid != null) {
        // Viewer (Audience) with active stream
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: remoteUid),
            connection: RtcConnection(channelId: channelId),
            useAndroidSurfaceView: true,
          ),
        );
      } else {
        // Viewer waiting for stream (clean, pro look without traditional loaders)
        return Container(
          color: Colors.black,
        );
      }
    }
  }
}
