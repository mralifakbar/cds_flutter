// Generated gradient artwork for gallery demos. Sample images only.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

final Uint8List _blue = base64Decode('iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAABKElEQVR42rXNCysDAQAH8L8kSZIkSZIkSbdz285e9nJ7uG3nNtKSJEmSJEmSjzkzZh7znhkzZsw89iX+X+D3A2b+GmK/jdGfpmitWa+16N+t09U2rdqufXVEPjsjla5wpTv00RMq96rlPvW9f+ptIFgaDJaGAq/DgeKIvzjqexF8z6JSkJSCafJJ9uYt3rzN8+jw5JzuHKi62/UAqu513YOqK847UHV/PaDqwYlbUHXVcQOqHq4HVF2zX4Oq6/YrUPWYLQuqPmvNgqrPWS9B1eOWC1D1+XpA1RfGz0HVF+UzUPUlOQOqvmzOgKqvmE9B1VdNaVD1NWMaVH3deAKqviEdg6pvSilQ9a2xFKj6tngEqr4jJkHVdw1JUPU9wyGo+r6QAFU/EBL/9QqSX8g1NL8AAAAASUVORK5CYII=');
final Uint8List _green = base64Decode('iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAABGUlEQVR42rXMD0cDcQAG4Pf3//p4bXW1trpWq7XVtbpaW12r1WokIiIREZGIiEREJCIiERGJiEhERNSneJ8P8KBludVbSnoN31tMeQsZrx549aybz7m5vKsV3Wzo4pKLIzdTttNVW41tpWYrdTvVsOWmnVwxE6smWjPRuhnfMGObprRlRrd1uKPDXT2yp4f3Qd118QDUXRcOQd114QjUXQ0dg7qr/Amouxo8BXVXA2eg7ip3Duqucheg7qr/EtRd9l2BusvsNai77L0BdZfBLai7DO5A3WXPPai77H4AdReZR1B3kX4CdRfpZ1B30fUC6i5Sr6DuovMN1F10vIO7+x/g7v4nuHv7F7h72ze4e/IH3D3xC+6e+PsH7sNaUE0vdUIAAAAASUVORK5CYII=');
final Uint8List _sunset = base64Decode('iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAABMElEQVR42rXMiSqDAQAH8P/7kCRJn212mPlss802O22zzTYjyZIkSZJIkiRJkleY+77v+77v+34ET/H/PcAPf6UJv9HEn5Kk70jyVzjlM5z6EUp7L05/CwqvAclLQPbslz8VKR99qgev+t6rufOIt4XaG7f+2mW4cpkuneYLh/XcbjuzO05tzpMC97HVc2TxHVr8B+bgfn4I1H3PFAF13zVGQd13jGWg7tuGclD3rbwKUPdNfSWo+4YuBuq+rqsCdV/TVoO6r+bWgLqviLWg7stiHaj7Uk49qPuipgHUfSG7EdR9Xt0E6j6nbgZ1n81qAXWfUbWCuk8r20DdpxTtoO6Tig5Q9wl5J6j7eGYXqPuYrBvUfVTaA+o+Iu0FdR+W9IG6D2X0g7rHhQFQ97gw+A/haiReQOpwLQAAAABJRU5ErkJggg==');

/// Gradient sample artwork, decoded from bytes so demos never hit the network.
abstract final class SampleArt {
  static ImageProvider get blue => MemoryImage(_blue);
  static ImageProvider get green => MemoryImage(_green);
  static ImageProvider get sunset => MemoryImage(_sunset);

  /// Bytes that are not an image, to show the error fallback.
  static ImageProvider get broken => MemoryImage(Uint8List.fromList(const [0, 1, 2, 3]));
}
