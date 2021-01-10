import 'dart:developer';

import 'package:animator/animator.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_openvpn/flutter_openvpn.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:ufas_app/blocs/authentication/authentication.dart';
import 'package:ufas_app/models/server.dart';
import 'package:ufas_app/pages/profile_page.dart';
import 'package:ufas_app/pages/servers_page.dart';
import 'package:ufas_app/services/ad_manager.dart';
import 'package:ufas_app/services/api_service.dart';
import '../helper.dart';
import '../models/models.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key key, this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var state = FlutterVpnState.disconnected;
  var openVpnState = "DISCONNECTED";
  final String logOut = 'assets/logout.svg';
  Future<dynamic> data;
  int serverType = 1;
  Server selectedServer = null;
  bool showAd;

  Future<Account> _getAccount() async {
    var _res = await APIService.getAccount(widget.user.token);
    if (widget.user.authorized && _res.active) {
      setState(() {
        showAd = false;
      });
    } else {
      setState(() {
        showAd = true;
      });
    }
    return _res;
  }

  @override
  void initState() {
    setState(() {
      data = _getAccount();
    });
    FlutterOpenvpn.init();
    FlutterVpn.prepare();
    FlutterVpn.onStateChanged.listen((s) {
      if (s == FlutterVpnState.connected) {
        // Device Connected
      }
      if (s == FlutterVpnState.disconnected) {
        // Device Disconnected
      }
      setState(() {
        state = s;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initTcpPlatformState() async {
    if (openVpnState == 'CONNECTED') {
      await FlutterOpenvpn.stopVPN();
    } else {
      var res = await FlutterOpenvpn.lunchVpn(
        """client
dev tun
proto tcp
remote 46.4.165.204 1194
auth-user-pass
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
cipher AES-256-CBC
ignore-unknown-option block-outside-dns
block-outside-dns
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIIDQjCCAiqgAwIBAgIUfEbWCK2KWzOGEo+PMJWFJ9PtbogwDQYJKoZIhvcNAQEL
BQAwEzERMA8GA1UEAwwIQ2hhbmdlTWUwHhcNMjAxMjI2MDkzNDA1WhcNMzAxMjI0
MDkzNDA1WjATMREwDwYDVQQDDAhDaGFuZ2VNZTCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBANopGuaLzwgde6R369gWnlPLW1yus3wf1UrrJudbkakQ8Ul/
nfD8tC3vBykmIeiA7LKCVDwVQ9EFhuPh4kS4npF4k+cWlPJdXNKB74xO0IuSTZrT
E8GPXxqfINv3D4iwry13Th1qOfJ+Qt1dVxWc3Wt3YBleTP94Z0a0Y+Xq3CfXABVh
xDhXOZ2bI4E11uftyXMvjasgDWXbl24BCfjkTIwVBZkNyVkjqUArWRDwDSa8+Z34
ENdfHidY4iNKJmjppdrleQueBx7j28VGf4bsF5lERMHsD54BT5ZN9LFEWoJpK1Rt
Pqfy6USwEwYoZjYGWebcGAw+0dXVxnWcSvoRgjkCAwEAAaOBjTCBijAdBgNVHQ4E
FgQUZQ9jDnZCJaX1Qf7PoY/PSou+f+0wTgYDVR0jBEcwRYAUZQ9jDnZCJaX1Qf7P
oY/PSou+f+2hF6QVMBMxETAPBgNVBAMMCENoYW5nZU1lghR8RtYIrYpbM4YSj48w
lYUn0+1uiDAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBBjANBgkqhkiG9w0BAQsF
AAOCAQEAGzVdv17Cbkz359RDN0bPXS4MnNpylkd4nnpzTbJb83LukCEidQ3yRzF4
rMY2/oddrZqRQMZx89zF6W5jS/gK+oOXgUEfXorOG9LTiXRU7MRinc/J6ZYeAV24
VDtIBse5w7veCHMVhmMPYOn/hL5z8arHjrlqcQ4y+Eo8ZgfD+N9mOArzXmSPnwlc
H1zPM/phUTcE7REb4l0xg+X3TYveWRjVO+Js+qvA/Z4ar8C0G7VfXWXJoQJ6OA68
EgbgpcBAq2mBpUGg/nDA1tY3t4FSVrDSt7pG6WzrbXjAmD9BKAEswaXWktht0Zgy
4y5H6pvDwxA/baACVs6zvc5VhELOVA==
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIDUDCCAjigAwIBAgIRAOzWe5vM+Ih93UABg67zh/swDQYJKoZIhvcNAQELBQAw
EzERMA8GA1UEAwwIQ2hhbmdlTWUwHhcNMjAxMjI2MDkzNDA1WhcNMzAxMjI0MDkz
NDA1WjASMRAwDgYDVQQDDAdUQ1AtTkVXMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEAlzkZpx8RkW6NBClV0ApknzDANA/MK6BMB4mTExfjxMGMW9faKWW2
87d5rraVLk9ifUUE+5VlZ1NwRPIQH2SCuBuzylUjQMqx68Yb05OsKWp7+yTI5l2M
xVaF1sdryKrq9+IDukuxeYGsu4e17z7ouulEg/WTF5Llq+kL/t28GdL4Lo9VDWyn
75WgcK+Ph5kSYNIfpB4nACIxfExL6mgm8T4WihkPAI5lsXFeRwcskGAbRh8ouoWk
UghxWtzBFn6cGIS9vbWL/sqjAVxi3GXmg9CMCoAyUI2mOd8QsaLKEZn1/Gk/e9TZ
h70gZFGrECct8Q94hTMMO0mUPzxC9p9z7wIDAQABo4GfMIGcMAkGA1UdEwQCMAAw
HQYDVR0OBBYEFLKmnRP4W1On0W2CE64ECo67Me4VME4GA1UdIwRHMEWAFGUPYw52
QiWl9UH+z6GPz0qLvn/toRekFTATMREwDwYDVQQDDAhDaGFuZ2VNZYIUfEbWCK2K
WzOGEo+PMJWFJ9PtbogwEwYDVR0lBAwwCgYIKwYBBQUHAwIwCwYDVR0PBAQDAgeA
MA0GCSqGSIb3DQEBCwUAA4IBAQAnCm7bWKMQqBzD7lVHsYi2M9zlmrlgvFj/zr63
gDByF9NvmRvxImbcKzNIy8g42O9VGuqxNMEZUXgr34ox7ZijaPJ1RbI5KxJkXuKW
KB5UzJmFVPbQSsYzwsB+mBkbEVVbKQqjg+calMMwbiu7JtKxmkKbTnjf3gVDzYrf
r7AqlP7YV10bk6JK1SsyV6PkBUAD+LYbbPk1/k939n5ZDDl42GwfgOq4qhn4cYKf
Ky/FClb0hYo4xXx5q0KGlFO12rTNuxxc5U6RwxRLvfAROroWLDuNT839C75DwONk
tBvKemeTfmb0LKhrN3o2ohXjzMPWXm0sbqcIZTM2bSdMSjY6
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCXORmnHxGRbo0E
KVXQCmSfMMA0D8wroEwHiZMTF+PEwYxb19opZbbzt3mutpUuT2J9RQT7lWVnU3BE
8hAfZIK4G7PKVSNAyrHrxhvTk6wpanv7JMjmXYzFVoXWx2vIqur34gO6S7F5gay7
h7XvPui66USD9ZMXkuWr6Qv+3bwZ0vguj1UNbKfvlaBwr4+HmRJg0h+kHicAIjF8
TEvqaCbxPhaKGQ8AjmWxcV5HByyQYBtGHyi6haRSCHFa3MEWfpwYhL29tYv+yqMB
XGLcZeaD0IwKgDJQjaY53xCxosoRmfX8aT971NmHvSBkUasQJy3xD3iFMww7SZQ/
PEL2n3PvAgMBAAECggEAFmOe165y5GxQtogEK3wOb79BBbQ9D0x5VThaLR6BW3Uo
ecSYiT6E+sp0Wpivt56LP27DkRgKXmTtH1gTaQJxlB6N3OwD/yjDdNvs7MNVXwBk
AMfucqTxHZp00FrQK3KavT6aPK/OQ+YeE9nA5v4SaPH2ce8e6wOVu4EShJaBrfTj
BK8iUhSprGYpcOPPk/sOreaJHvio2Ha8WUahPDMm0QsokfvYu2tzpQe5DvUf/3Tk
ApsX0NWRBrN6UYLPJen2Jg49yXSn7DgXjTdxT8Px7fwH+44Wj2f0Q9SNxnDxd/1B
COrw5ttmWLNA3uaH6Nd7j76KSqPRRW0Ei6rwyt+aiQKBgQDFOk5LiFS53FatkwQx
6V6gxPOSOSlIIxtWdp2GrVrGe/UjQ8i2hMfFD8A3JXhYzZ4BQqN7035vRhosBlXR
Td1q7Nna27Pm+QMRAvAmLWisnzanPBfTfuUzgvb3g5CrruXaMKkfx/kZ0aWTgZQ/
2YoNmNnX32/lM6Qw5r4+h9ihywKBgQDESUjLOPos/5guplYbo2H5slDsunTBtM2H
aYuPry1uszv60Q3d0bPQc80d/AJcs+F8W8lI6Ro1A16BkHDc0jr6+mzqVLyq/RKV
u29c3bUuO7iGp3axkj6h11z88xxiYLtqi+Bejbnkss36Uh7wBL0KM+cpalE0PdtR
H3bocdOh7QKBgQCFPqLuvKgg+Q9GLPDEl5lqnCTCQQP2zGEHxRMfjbaqKcyvinfr
d0FPjRibKSFpPWDmERNJ8NSWcJH19EG+KhDQ0DtOdOfRv6GmuIluAXeaR+YwjZS7
Ohu29V/MUIJIutxm0EEyS3OrUcu/H+f8SwfNr9pc0YNTIdRnhTw6GqTsiQKBgQCQ
Mw5pTbhs6nDQhJ5pu4O0vs04vFoeHEeJnX5L1nPYCZCc2IwJU494KjqcNpE9rWCP
zZZ4G9eG7qy1Hnnrn/54dxUgqZPZQgYvPf24CaCbEIClW82U8k1U9DR6F9fYZhwJ
UC1LCW9xlfJAXaggyDpgjnTaNiLl8DN4y1a9uTGymQKBgE5g8ODYzOifmFPZPuG/
4z4D/1KGgyvuLKWcRzERFdXA6oXp7Ggp5vkejUonGBzhI6bBfFThnR3PA8J0sT0t
cYMwIR51Q9fBM2i8mUooJ7mI3gQ/Ma0XoOuezi7mo2Ja2ZjonJIKR5QqkyibtAuD
JY4DKXEAz4ApMdfma5E0YHI8
-----END PRIVATE KEY-----
</key>
<tls-crypt>
-----BEGIN OpenVPN Static key V1-----
d23775c37425a2d6404ab9566f557e33
d41a89b5695594d74b6cffe18a7931b5
a725729f176850e559254bb61a7d0e8e
d4c3902f6ad1404fc125131fb4df713e
a03bd0d0fdcf11f7ee0fc514cd7fcf26
ab9c3231efb0f2e211099b26322a86b7
b2d5b4d67543d6e74b3aa09cd9455eb1
c906940309fcf5968a3bad4b69c13d4e
3cef310bf511507350a9a182bc65acef
9b0de9f9b303735d26cea26fbeca715b
36ea7148c249aa59d56a7124c3c2e5c8
69c4cee754302114eef50e4d23370f89
6fb4dbdf8796cea9d900ded764adee73
4dc0e7953f9700ae832e506e74487274
8493d1d190145fc89988a9ab9daf40a2
5d283229276aea15742d3dad24200b5a
-----END OpenVPN Static key V1-----
</tls-crypt>""",
        (isProfileLoaded) {
          print('isProfileLoaded : $isProfileLoaded');
        },
        (vpnActivated) {
          setState(() {
            openVpnState = vpnActivated;
          });
          print('vpnActivated : $vpnActivated');
        },
        user: 'b11',
        pass: 'yfK8b6&u',
      );
    }
  }

  Future<void> initUdpPlatformState() async {
    if (openVpnState == 'CONNECTED') {
      await FlutterOpenvpn.stopVPN();
    } else {
      await FlutterOpenvpn.lunchVpn("""client
proto udp
explicit-exit-notify
remote 46.4.165.203 1194
dev tun
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
verify-x509-name server_9ZZNcDrSVgn4mQ6d name
auth SHA256
auth-nocache
cipher AES-128-GCM
tls-client
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
ignore-unknown-option block-outside-dns
setenv opt block-outside-dns # Prevent Windows 10 DNS leak
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIIBwTCCAWegAwIBAgIJAJpJ8HoBNNEKMAoGCCqGSM49BAMCMB4xHDAaBgNVBAMM
E2NuX09oMUhScUhzeVRDMDZkZVAwHhcNMjAxMjI1MTkwOTQ1WhcNMzAxMjIzMTkw
OTQ1WjAeMRwwGgYDVQQDDBNjbl9PaDFIUnFIc3lUQzA2ZGVQMFkwEwYHKoZIzj0C
AQYIKoZIzj0DAQcDQgAEBKVdm0xDzXjHEum1Q/y6lhWVdbzwS9hR7F0APZkH0Bqd
GJuywqv8Q0JxdWxxBBFVMhyV9xYDcp1vuuq4qypSxKOBjTCBijAdBgNVHQ4EFgQU
+owv/JVaFwRjfJ2qe89sd6FBkacwTgYDVR0jBEcwRYAU+owv/JVaFwRjfJ2qe89s
d6FBkaehIqQgMB4xHDAaBgNVBAMME2NuX09oMUhScUhzeVRDMDZkZVCCCQCaSfB6
ATTRCjAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBBjAKBggqhkjOPQQDAgNIADBF
AiEAoiB8f/nDVxeU1Ka+l/hLPiWFgAjFizjqOQxuHPbhp0UCIAjv2Tp2TdSaYkQe
O2N5HrYA8zt/wE4ZprE70FITOChP
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIBzzCCAXagAwIBAgIRAO4Rjwrp2DxOU/cmzQwXx78wCgYIKoZIzj0EAwIwHjEc
MBoGA1UEAwwTY25fT2gxSFJxSHN5VEMwNmRlUDAeFw0yMDEyMjUxOTEwMDRaFw0y
MzAzMzAxOTEwMDRaMBMxETAPBgNVBAMMCFVEUC1MQVNUMFkwEwYHKoZIzj0CAQYI
KoZIzj0DAQcDQgAEF54jU3KEfu7SGQff1SDe+aZlhzqkx7mVUdU4lXqdOu0uNQ6H
dHlkxaqNqtsD9atJVvd/Rf1zVV+tLSrwUnST06OBnzCBnDAJBgNVHRMEAjAAMB0G
A1UdDgQWBBTehjlxXu+gAt82HO9wdF+l0Z25SjBOBgNVHSMERzBFgBT6jC/8lVoX
BGN8nap7z2x3oUGRp6EipCAwHjEcMBoGA1UEAwwTY25fT2gxSFJxSHN5VEMwNmRl
UIIJAJpJ8HoBNNEKMBMGA1UdJQQMMAoGCCsGAQUFBwMCMAsGA1UdDwQEAwIHgDAK
BggqhkjOPQQDAgNHADBEAiAwmf29pedIYdoShrrlqyplYcErRw+L3vAvGSKN9oNg
MwIgWa3INGaP3/qlEH33vCne0V/zj6PPLGHxUyqhrspr4WY=
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg1ZoFOytg+n7jE46f
BVOPpvZm4WydZP80JmaRMpxHxW+hRANCAAQXniNTcoR+7tIZB9/VIN75pmWHOqTH
uZVR1TiVep067S41Dod0eWTFqo2q2wP1q0lW939F/XNVX60tKvBSdJPT
-----END PRIVATE KEY-----
</key>
<tls-crypt>
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
d8fddb98908ed8f54e5e206f946b9d9c
6648290dc464af31d99bdea383346307
891b82dfe0a2deb4704baca6038abd48
ddc989d9ff95ca95ed5d191278e4195e
88ea8a3313c25eda83bac0742f89edc4
22da00d7067ae15827ab82f2deb84d9b
814490e3d1c9274ba6e1e5eacd41f59f
f2504c7dc89c921c8f11791e72f05c46
8abc3eb6bc6242af461c9c715c39877f
be82723900c5bdfdb4972d15e1642786
87a1a7d6dd581dc8371358e1366c7dc4
23e3dd3ee8e61fb38ac2a41b5a736208
527a622b0801f955c866838e57e6c563
cb182ff253ef5214d4a835988d3f83cf
ded829826f3047fe3504f04bfbf765da
754f93eeb9c4c29370775b0ef97302ae
-----END OpenVPN Static key V1-----
</tls-crypt>""", (isProfileLoaded) {
        print('isProfileLoaded : $isProfileLoaded');
      }, (vpnActivated) {
        setState(() {
          openVpnState = vpnActivated;
        });
        print('vpnActivated : $vpnActivated');
      }, user: 'behzad', pass: 'y4p79SMb&');
    }
  }

  void ikevConnect() {
    if (state == FlutterVpnState.connected ||
        state == FlutterVpnState.genericError) {
      FlutterVpn.disconnect();
    } else {
      FlutterVpn.simpleConnect(
          "grikvewhsona.ufasvpn.com", "behzad", "1234@qwerB");
    }
  }

  void connectVpn() async {
    switch (serverType) {
      case 2:
        {
          log("vpn connection type => openVPN(TCP)");
          initTcpPlatformState();
        }
        break;

      case 3:
        {
          log("vpn connection type => openVPN(UDP)");
          initUdpPlatformState();
        }
        break;

      default:
        {
          log("vpn connection type => ikev");
          ikevConnect();
        }
        break;
    }
  }

  Container _itemDown() => Container(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          width: MediaQuery.of(context).size.width / 1.5,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[300],
              width: 1.0,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<int>(
            isDense: true,
            items: [
              DropdownMenuItem(
                value: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image.asset(
                      'assets/ikev_logo.png',
                      width: 25,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Ikev2",
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image.asset(
                      'assets/openvpn_logo.png',
                      width: 25,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "OpenVPN(TCP)",
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image.asset(
                      'assets/openvpn_logo.png',
                      width: 25,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "OpenVPN(UDP)",
                    ),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                serverType = value;
              });
            },
            value: serverType,
            isExpanded: false,
            elevation: 0,
          ),
        ),
      );

  Widget buildUi(BuildContext context) {
    if (state == FlutterVpnState.connected) {
      //bağlı
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "TAP TO\nTURN OFF VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.green,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
            ],
          ))
        ],
      );
    } else if (state == FlutterVpnState.connecting) {
      // bağlanıyor
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Animator(
                duration: Duration(seconds: 2),
                repeats: 0,
                builder: (anim) => FadeTransition(
                  opacity: anim,
                  child: Text(
                    "CONNECTING",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Montserrat-SemiBold",
                        fontSize: 20.0),
                  ),
                ),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SpinKitRipple(
                color: Colors.black,
                size: 190.0,
              ),
              SizedBox(height: screenAwareSize(50.0, context)),
              // serverConnection(context),
              SizedBox(height: screenAwareSize(30.0, context)),
              Text(
                "CONNECTING VPN SERVER",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 12.0),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
            ],
          ))
        ],
      );
    } else {
      // bağlı değil
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "TAP TO\nTURN ON VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      color: Colors.green,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(40.0, context)),
            ],
          ))
        ],
      );
    }
  }

  Widget buildOpenVpnUi(BuildContext context) {
    if (openVpnState == "CONNECTED") {
      //bağlı
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "TAP TO\nTURN OFF VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.green,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
            ],
          ))
        ],
      );
    } else if (openVpnState == "VPN_GENERATE_CONFIG" ||
        openVpnState == "GET_CONFIG" ||
        openVpnState == "ASSIGN_IP" ||
        openVpnState == "AUTH" ||
        openVpnState == "WAIT") {
      // bağlanıyor
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Animator(
                duration: Duration(seconds: 2),
                repeats: 0,
                builder: (anim) => FadeTransition(
                  opacity: anim,
                  child: Text(
                    "CONNECTING",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Montserrat-SemiBold",
                        fontSize: 20.0),
                  ),
                ),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SpinKitRipple(
                color: Colors.black,
                size: 190.0,
              ),
              SizedBox(height: screenAwareSize(50.0, context)),
              // serverConnection(context),
              SizedBox(height: screenAwareSize(30.0, context)),
              Text(
                "CONNECTING VPN SERVER",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 12.0),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
            ],
          ))
        ],
      );
    } else {
      // bağlı değil
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "TAP TO\nTURN ON VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      color: Colors.green,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(40.0, context)),
            ],
          ))
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 60,
            ),
            (widget.user.authorized)
                ? ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Profile"), Icon(Icons.person)],
                    ),
                    onTap: () {
                      pushReplacement(context, ProfilePage(user: widget.user));
                    },
                  )
                : SizedBox(
                    height: 0,
                  ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Logout"), Icon(Icons.logout)],
              ),
              onTap: () {
                authBloc.add(UserLoggedOut());
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              (serverType == 1) ? buildUi(context) : buildOpenVpnUi(context),
              // _itemDown(),
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            serverType = 1;
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: (serverType == 1)
                                ? BoxDecoration(
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white)
                                : BoxDecoration(),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/ikev_logo.png",
                                  width: 30,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("     Ikev     ",
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ))),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            serverType = 2;
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: (serverType == 2)
                                ? BoxDecoration(
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white)
                                : BoxDecoration(),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/openvpn_logo.png",
                                  width: 30,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("ovpn (tcp)",
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ))),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            serverType = 3;
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: (serverType == 3)
                                ? BoxDecoration(
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white)
                                : BoxDecoration(),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/openvpn_logo.png",
                                  width: 30,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("ovpn (udp)",
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ))),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300],
                    width: 1.0,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FlatButton(
                  child: (selectedServer != null)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              selectedServer.flag,
                              width: 30,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(selectedServer.country),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_fixed),
                            SizedBox(
                              width: 10,
                            ),
                            Text('AutoSelect'),
                          ],
                        ),
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ServersPage(user: widget.user)));
                    setState(() {
                      selectedServer = result;
                    });
                  },
                ),
              ),
              // FutureBuilder<Account>(
              //     future: _getAccount(),
              //     builder:
              //         (BuildContext context, AsyncSnapshot<Account> snapshot) {
              //       if (snapshot.hasData) {
              //         return Text(snapshot.data.active.toString());
              //       } else {
              //         return CircularProgressIndicator();
              //       }
              //     }),
            ],
          ),
        ),
      ),
    );
  }
}
