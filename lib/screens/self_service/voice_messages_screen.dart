// ============================================================
// ISF HR Portal — Voice Messages Screen
// File: lib/screens/self_service/voice_messages_screen.dart
//
// Features:
//   - Inbox / Sent tabs
//   - Voice message list with waveform visualizer
//   - Animated playback bar with play/pause/seek
//   - Record new voice message FAB → compose sheet
//   - Compose sheet: recipient picker, recording UI
//     with live waveform animation & timer
//   - Send recorded message
//   - Swipe to delete messages
//   - Mark as read / unread
//   - Message detail: full waveform + transcript stub
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const successDark = Color(0xFF16A34A);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSec = Color(0xFF64748B);
  static const textTert = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);
  static const border = Color(0xFFE2E8F0);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
enum _VoiceTab { inbox, sent }

class _Contact {
  final String id, name, initials, role;
  final Color avatarColor;
  const _Contact({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.avatarColor,
  });
}

class _VoiceMessage {
  final String id;
  final _Contact from;
  final _Contact to;
  final String timestamp;
  final int durationSec;
  final String? transcriptStub;
  bool isRead;
  bool isPlaying = false;
  double playProgress = 0.0; // 0.0 – 1.0
  final List<double> waveform; // normalized bar heights

  _VoiceMessage({
    required this.id,
    required this.from,
    required this.to,
    required this.timestamp,
    required this.durationSec,
    this.transcriptStub,
    this.isRead = false,
    required this.waveform,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
const _me = _Contact(
  id: 'me',
  name: 'Amit Patil',
  initials: 'AP',
  role: 'You',
  avatarColor: Color(0xFF2563EB),
);

const _contacts = [
  _Contact(
      id: 'pm',
      name: 'Priya Mehta',
      initials: 'PM',
      role: 'Direct Manager',
      avatarColor: Color(0xFF6366F1)),
  _Contact(
      id: 'sp',
      name: 'Sneha Patil',
      initials: 'SP',
      role: 'HR Manager',
      avatarColor: Color(0xFFEC4899)),
  _Contact(
      id: 'rk',
      name: 'Rajesh Kumar',
      initials: 'RK',
      role: 'Senior Manager',
      avatarColor: Color(0xFF0EA5E9)),
  _Contact(
      id: 'vk',
      name: 'Vikram Kadam',
      initials: 'VK',
      role: 'HR Executive',
      avatarColor: Color(0xFF0D9488)),
  _Contact(
      id: 'ar',
      name: 'Anjali Rao',
      initials: 'AR',
      role: 'HR Executive',
      avatarColor: Color(0xFF7C3AED)),
];

// Deterministic waveform from a seed
List<double> _waveform(int seed, int bars) {
  final rng = math.Random(seed);
  return List.generate(bars, (_) => 0.15 + rng.nextDouble() * 0.85);
}

final _mockInbox = [
  _VoiceMessage(
    id: 'vm1',
    from: _contacts[0],
    to: _me,
    timestamp: 'Today, 10:23 AM',
    durationSec: 28,
    transcriptStub:
        'Hi Amit, just wanted to check in on the sprint deliverables. Can you confirm by EOD?',
    isRead: false,
    waveform: _waveform(1, 30),
  ),
  _VoiceMessage(
    id: 'vm2',
    from: _contacts[1],
    to: _me,
    timestamp: 'Today, 09:05 AM',
    durationSec: 14,
    transcriptStub:
        'Amit, your leave application has been approved. Have a great time!',
    isRead: true,
    waveform: _waveform(2, 30),
  ),
  _VoiceMessage(
    id: 'vm3',
    from: _contacts[2],
    to: _me,
    timestamp: 'Yesterday, 04:45 PM',
    durationSec: 42,
    transcriptStub:
        'Please review the Q2 roadmap deck before the board meeting on Friday.',
    isRead: true,
    waveform: _waveform(3, 30),
  ),
  _VoiceMessage(
    id: 'vm4',
    from: _contacts[3],
    to: _me,
    timestamp: '27 Apr, 11:30 AM',
    durationSec: 9,
    transcriptStub: 'Your PF transfer request has been processed.',
    isRead: false,
    waveform: _waveform(4, 30),
  ),
  _VoiceMessage(
    id: 'vm5',
    from: _contacts[4],
    to: _me,
    timestamp: '26 Apr, 03:20 PM',
    durationSec: 19,
    transcriptStub:
        'IT declaration window closes on 15 Dec. Please complete your declarations soon.',
    isRead: true,
    waveform: _waveform(5, 30),
  ),
];

final _mockSent = [
  _VoiceMessage(
    id: 'sv1',
    from: _me,
    to: _contacts[0],
    timestamp: 'Today, 10:35 AM',
    durationSec: 22,
    transcriptStub:
        'Hi Priya, sprint items are on track. Will share the update by 5 PM.',
    isRead: true,
    waveform: _waveform(10, 30),
  ),
  _VoiceMessage(
    id: 'sv2',
    from: _me,
    to: _contacts[1],
    timestamp: '28 Apr, 02:10 PM',
    durationSec: 15,
    transcriptStub: 'Thank you Sneha! I have submitted my IT declaration.',
    isRead: true,
    waveform: _waveform(11, 30),
  ),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
String _fmtDuration(int sec) {
  final m = sec ~/ 60;
  final s = sec % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class VoiceMessagesScreen extends StatefulWidget {
  const VoiceMessagesScreen({super.key});

  @override
  State<VoiceMessagesScreen> createState() => _VoiceMessagesScreenState();
}

class _VoiceMessagesScreenState extends State<VoiceMessagesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  _VoiceTab _activeTab = _VoiceTab.inbox;

  final List<_VoiceMessage> _inbox = List.from(_mockInbox);
  final List<_VoiceMessage> _sent = List.from(_mockSent);

  // Playback simulation
  _VoiceMessage? _currentlyPlaying;
  Timer? _playTimer;

  int get _unreadCount => _inbox.where((m) => !m.isRead).length;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() => _activeTab =
            _tabCtrl.index == 0 ? _VoiceTab.inbox : _VoiceTab.sent);
      });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _playTimer?.cancel();
    super.dispose();
  }

  // ── Playback ────────────────────────────────
  void _togglePlay(_VoiceMessage msg) {
    setState(() {
      // Mark read
      msg.isRead = true;

      if (_currentlyPlaying != null && _currentlyPlaying!.id != msg.id) {
        _currentlyPlaying!.isPlaying = false;
        _currentlyPlaying!.playProgress = 0;
        _playTimer?.cancel();
      }

      if (msg.isPlaying) {
        msg.isPlaying = false;
        _playTimer?.cancel();
        _currentlyPlaying = null;
      } else {
        msg.isPlaying = true;
        _currentlyPlaying = msg;
        _startPlayback(msg);
      }
    });
  }

  void _startPlayback(_VoiceMessage msg) {
    _playTimer?.cancel();
    final totalTicks = msg.durationSec;
    int elapsed = (msg.playProgress * totalTicks).round();

    _playTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed++;
      if (!mounted) return;
      setState(() {
        msg.playProgress = elapsed / totalTicks;
        if (elapsed >= totalTicks) {
          msg.isPlaying = false;
          msg.playProgress = 0;
          _currentlyPlaying = null;
          _playTimer?.cancel();
        }
      });
    });
  }

  void _seekPlayback(_VoiceMessage msg, double pct) {
    setState(() {
      msg.playProgress = pct.clamp(0.0, 1.0);
      if (msg.isPlaying) {
        _playTimer?.cancel();
        _startPlayback(msg);
      }
    });
  }

  // ── Delete ──────────────────────────────────
  void _deleteMessage(_VoiceMessage msg) {
    if (msg.isPlaying) {
      _playTimer?.cancel();
      _currentlyPlaying = null;
    }
    setState(() {
      if (_activeTab == _VoiceTab.inbox) {
        _inbox.removeWhere((m) => m.id == msg.id);
      } else {
        _sent.removeWhere((m) => m.id == msg.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Message deleted',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: _C.textSec,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Show compose sheet ───────────────────────
  void _showCompose() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ComposeSheet(
        onSend: (msg) {
          setState(() => _sent.insert(0, msg));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Voice message sent ✅',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            backgroundColor: _C.successDark,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ));
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCompose,
        backgroundColor: _C.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.mic_outlined, size: 20),
        label: const Text('New Message',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildList(_inbox, isInbox: true),
              _buildList(_sent, isInbox: false),
            ],
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: _C.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: _C.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Voice Messages',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 22),
            color: _C.textSec,
            onPressed: () {},
            tooltip: 'Search',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────────
  Widget _buildTabBar() => Container(
        color: _C.card,
        child: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Inbox'),
              if (_unreadCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                      color: _C.error, borderRadius: BorderRadius.circular(10)),
                  child: Text('$_unreadCount',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ],
            ])),
            const Tab(text: 'Sent'),
          ],
          labelColor: _C.primary,
          unselectedLabelColor: _C.textSec,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorColor: _C.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: _C.border,
        ),
      );

  // ─────────────────────────────────────────────
  // MESSAGE LIST
  // ─────────────────────────────────────────────
  Widget _buildList(List<_VoiceMessage> messages, {required bool isInbox}) {
    if (messages.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.voicemail_rounded,
                  size: 36, color: _C.primary)),
          const SizedBox(height: 16),
          Text(isInbox ? 'No voice messages' : 'No sent messages',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 6),
          Text(
            isInbox
                ? 'Voice messages from your team will appear here.'
                : 'Tap the mic button to record and send a message.',
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 13, color: _C.textSec, height: 1.5),
          ),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final msg = messages[i];
        return Dismissible(
          key: Key(msg.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
                color: _C.errorLight, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.delete_outline_rounded,
                color: _C.error, size: 26),
          ),
          onDismissed: (_) => _deleteMessage(msg),
          child: _VoiceMessageCard(
            message: msg,
            isInbox: isInbox,
            onTogglePlay: () => _togglePlay(msg),
            onSeek: (pct) => _seekPlayback(msg, pct),
            onMarkRead: () => setState(() => msg.isRead = true),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// VOICE MESSAGE CARD
// ─────────────────────────────────────────────
class _VoiceMessageCard extends StatelessWidget {
  final _VoiceMessage message;
  final bool isInbox;
  final VoidCallback onTogglePlay;
  final void Function(double) onSeek;
  final VoidCallback onMarkRead;

  const _VoiceMessageCard({
    required this.message,
    required this.isInbox,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final contact = isInbox ? message.from : message.to;
    final isUnread = isInbox && !message.isRead;
    final elapsed = (message.playProgress * message.durationSec).round();

    return GestureDetector(
      onLongPress: onMarkRead,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: message.isPlaying
                ? _C.primary.withValues(alpha: .5)
                : isUnread
                    ? _C.primary.withValues(alpha: .25)
                    : _C.border,
            width: message.isPlaying || isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: message.isPlaying
                  ? _C.primary.withValues(alpha: .08)
                  : Colors.black.withValues(alpha: .04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Top row: avatar + name + time + unread dot
            Row(children: [
              Stack(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: contact.avatarColor, shape: BoxShape.circle),
                  child: Center(
                      child: Text(contact.initials,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white))),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: _C.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: _C.card, width: 2))),
                  ),
              ]),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      isInbox ? contact.name : 'To: ${contact.name}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isUnread ? FontWeight.w800 : FontWeight.w600,
                          color: _C.textPrimary),
                    ),
                    Text(contact.role,
                        style:
                            const TextStyle(fontSize: 10, color: _C.textSec)),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(message.timestamp,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isUnread ? FontWeight.w700 : FontWeight.w400,
                        color: isUnread ? _C.primary : _C.textTert)),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.mic_none_rounded,
                        size: 10, color: _C.textSec),
                    const SizedBox(width: 2),
                    Text(_fmtDuration(message.durationSec),
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _C.textSec)),
                  ]),
                ),
              ]),
            ]),
            const SizedBox(height: 12),

            // Playback row
            Row(children: [
              // Play / Pause button
              GestureDetector(
                onTap: onTogglePlay,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: message.isPlaying ? _C.primary : _C.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    message.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 22,
                    color: message.isPlaying ? Colors.white : _C.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Waveform + seek
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    final box = context.findRenderObject() as RenderBox;
                    final localX = d.localPosition.dx;
                    final waveW = box.size.width - 40 - 10 - 10;
                    onSeek((localX / waveW).clamp(0.0, 1.0));
                  },
                  child: _WaveformBar(
                    bars: message.waveform,
                    progress: message.playProgress,
                    isPlaying: message.isPlaying,
                    primaryColor: _C.primary,
                    trackColor: _C.border,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Time counter
              SizedBox(
                width: 36,
                child: Text(
                  message.isPlaying || message.playProgress > 0
                      ? _fmtDuration(elapsed)
                      : _fmtDuration(message.durationSec),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _C.textSec,
                      fontFamily: 'monospace'),
                ),
              ),
            ]),

            // Transcript stub
            if (message.transcriptStub != null) ...[
              const SizedBox(height: 9),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: _C.surface, borderRadius: BorderRadius.circular(8)),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.subtitles_outlined,
                          size: 12, color: _C.textTert),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          message.transcriptStub!,
                          style: const TextStyle(
                              fontSize: 11, color: _C.textSec, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WAVEFORM BAR PAINTER
// ─────────────────────────────────────────────
class _WaveformBar extends StatelessWidget {
  final List<double> bars;
  final double progress;
  final bool isPlaying;
  final Color primaryColor;
  final Color trackColor;

  const _WaveformBar({
    required this.bars,
    required this.progress,
    required this.isPlaying,
    required this.primaryColor,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: CustomPaint(
        painter: _WaveformPainter(
          bars: bars,
          progress: progress,
          playedColor: primaryColor,
          unplayedColor: trackColor,
          isPlaying: isPlaying,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> bars;
  final double progress;
  final Color playedColor;
  final Color unplayedColor;
  final bool isPlaying;

  const _WaveformPainter({
    required this.bars,
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = bars.length;
    final barW = (size.width / n) * 0.55;
    final gapW = (size.width / n) * 0.45;
    final maxH = size.height * 0.9;
    final midY = size.height / 2;
    final progPx = progress * size.width;

    for (int i = 0; i < n; i++) {
      final x = i * (barW + gapW);
      final barH = bars[i] * maxH;
      final center = x + barW / 2;
      final played = center <= progPx;

      final paint = Paint()
        ..color = played ? playedColor : unplayedColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(center, midY),
              width: barW,
              height: barH.clamp(3, maxH)),
          const Radius.circular(2),
        ),
        paint,
      );
    }

    // Playhead
    if (progress > 0 && progress < 1) {
      canvas.drawRect(
        Rect.fromLTWH(progPx - 1, 0, 2, size.height),
        Paint()
          ..color = playedColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.isPlaying != isPlaying;
}

// ─────────────────────────────────────────────
// COMPOSE SHEET (Record + Send)
// ─────────────────────────────────────────────
class _ComposeSheet extends StatefulWidget {
  final void Function(_VoiceMessage) onSend;
  const _ComposeSheet({required this.onSend});

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet>
    with TickerProviderStateMixin {
  _Contact? _recipient;
  bool _isRecording = false;
  bool _hasRecording = false;
  bool _isSending = false;
  int _recordSec = 0;
  Timer? _recTimer;

  // Live waveform animation
  late final AnimationController _waveCtrl;
  List<double> _liveBars = List.generate(20, (_) => 0.15);
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120))
      ..addListener(_animateBars)
      ..repeat();
  }

  void _animateBars() {
    if (_isRecording) {
      setState(() {
        _liveBars = List.generate(20, (i) => 0.1 + _rng.nextDouble() * 0.9);
      });
    } else if (!_hasRecording) {
      setState(() {
        _liveBars = List.generate(20, (_) => 0.08);
      });
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _recTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _hasRecording = false;
      _recordSec = 0;
    });
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordSec++);
      if (_recordSec >= 120) _stopRecording();
    });
  }

  void _stopRecording() {
    _recTimer?.cancel();
    setState(() {
      _isRecording = false;
      _hasRecording = true;
      _liveBars = _waveform(42 + _recordSec, 20);
    });
  }

  void _discardRecording() {
    setState(() {
      _hasRecording = false;
      _recordSec = 0;
      _liveBars = List.generate(20, (_) => 0.08);
    });
  }

  Future<void> _send() async {
    if (_recipient == null) {
      _showErr('Select a recipient');
      return;
    }
    if (!_hasRecording) {
      _showErr('Record a message first');
      return;
    }

    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final msg = _VoiceMessage(
      id: 'sv_${DateTime.now().millisecondsSinceEpoch}',
      from: _me,
      to: _recipient!,
      timestamp: 'Just now',
      durationSec: _recordSec.clamp(1, 120),
      transcriptStub: null,
      isRead: true,
      waveform: List<double>.from(_liveBars) + _waveform(99, 10),
    );

    Navigator.pop(context);
    widget.onSend(msg);
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _C.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 36 + bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _C.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 18),

        // Title
        Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.mic_outlined, size: 18, color: _C.primary)),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('New Voice Message',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            Text('Record up to 2 minutes',
                style: TextStyle(fontSize: 12, color: _C.textSec)),
          ]),
        ]),
        const SizedBox(height: 20),

        // Recipient picker
        const Align(
            alignment: Alignment.centerLeft,
            child: Text('To *',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.border, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<_Contact>(
              value: _recipient,
              hint: const Text('Select recipient',
                  style: TextStyle(fontSize: 13, color: _C.textTert)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20, color: _C.textSec),
              style: const TextStyle(
                  fontSize: 13,
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w500),
              onChanged: (v) => setState(() => _recipient = v),
              items: _contacts
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(children: [
                          Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                  color: c.avatarColor, shape: BoxShape.circle),
                              child: Center(
                                  child: Text(c.initials,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)))),
                          const SizedBox(width: 10),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                Text(c.role,
                                    style: const TextStyle(
                                        fontSize: 10, color: _C.textSec)),
                              ]),
                        ]),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Recording area
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: _isRecording ? const Color(0xFFFFF1F2) : _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isRecording ? _C.error.withValues(alpha: .4) : _C.border,
              width: _isRecording ? 1.5 : 1,
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Timer
            if (_isRecording || _hasRecording) ...[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (_isRecording)
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: _C.error, shape: BoxShape.circle)),
                if (_isRecording) const SizedBox(width: 6),
                Text(
                  _fmtDuration(_recordSec),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: _isRecording ? _C.error : _C.textPrimary),
                ),
              ]),
              const SizedBox(height: 8),
            ],

            // Live waveform
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: CustomPaint(
                  painter: _WaveformPainter(
                    bars: _liveBars,
                    progress: 0,
                    playedColor: _isRecording ? _C.error : _C.primary,
                    unplayedColor:
                        _isRecording ? _C.error.withValues(alpha: .3) : _C.border,
                    isPlaying: false,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),

            if (!_isRecording && !_hasRecording) ...[
              const SizedBox(height: 6),
              const Text('Tap the mic button to start recording',
                  style: TextStyle(fontSize: 11, color: _C.textTert)),
            ],
          ]),
        ),
        const SizedBox(height: 18),

        // Controls row
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Discard
          if (_hasRecording) ...[
            GestureDetector(
              onTap: _discardRecording,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: _C.errorLight,
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 22, color: _C.error),
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Record / Stop button
          GestureDetector(
            onTap: _isRecording
                ? _stopRecording
                : (_hasRecording ? null : _startRecording),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _isRecording
                    ? _C.error
                    : _hasRecording
                        ? _C.textDisabled
                        : _C.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isRecording ? _C.error : _C.primary).withValues(alpha: .35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),

          // Send
          if (_hasRecording) ...[
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _isSending ? null : _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: _C.successDark,
                    borderRadius: BorderRadius.circular(14)),
                child: _isSending
                    ? const Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5)))
                    : const Icon(Icons.send_rounded,
                        size: 22, color: Colors.white),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        Text(
          _isRecording
              ? 'Recording… tap stop when done'
              : _hasRecording
                  ? 'Tap send to deliver, or delete to re-record'
                  : 'Tap mic to start recording',
          style: const TextStyle(fontSize: 11, color: _C.textSec),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}
