import 'package:url_launcher/url_launcher.dart';

class CallsEmailWebService {
  void call(String number) => launch("tel://$number");

  void sendSms(String number) => launch("sms:$number");

  void sendEmail(String email) => launch("mailto:$email");

//  void openUrl(String url) => launch(url);

  void openUrl(String url) async {
//    url = 'www.flexiwaresolutions.com';
    url = url.replaceAll("www.", "http://");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
