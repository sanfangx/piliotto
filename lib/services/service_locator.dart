import 'audio_handler.dart';
import 'audio_session.dart';
import 'sign_in_service.dart';
import 'package:piliotto/ottohub/api/services/api_service.dart';

late VideoPlayerServiceHandler videoPlayerServiceHandler;
late AudioSessionHandler audioSessionHandler;
late SignInService signInService;

Future<void> setupServiceLocator() async {
  final audio = await initAudioService();
  videoPlayerServiceHandler = audio;
  audioSessionHandler = AudioSessionHandler();

  // 初始化签到服务并自动签到
  signInService = SignInService();
  // 只有用户已登录才进行自动签到
  if (ApiService.getToken() != null) {
    await signInService.autoSignIn();
  }
}
