// ============================================================
// ISF HR Portal — Documents Screen
// File: lib/screens/personal/documents_screen.dart
//
// Features:
//   - Category filter tabs (All / Personal / Employment / Compliance / Training)
//   - Document list with type icons, metadata, 3-dot menu
//   - Upload FAB → bottom sheet form
//   - Download with animated progress per card
//   - Empty state when no docs in category
//   - Long-press multi-select + bulk actions
//
// Dependencies: cached_network_image (already in pubspec.yaml)
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

// ─── Replace with actual imports ──────────────────────────
// import '../../theme/app_colors.dart';
// import '../../theme/app_text_styles.dart';
// ──────────────────────────────────────────────────────────

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const primaryDark = Color(0xFF1D4ED8);
  static const accent = Color(0xFF6366F1);
  static const accentLight = Color(0xFFEEF2FF);
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF9C3);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
  static const teal = Color(0xFF0D9488);
  static const tealLight = Color(0xFFF0FDFA);
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSec = Color(0xFF64748B);
  static const textTert = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
enum DocType { pdf, image, excel, word, other }

enum DocCategory { personal, employment, compliance, training }

class _Document {
  final String id;
  final String name;
  final DocType type;
  final DocCategory category;
  final String uploadedDate;
  final String fileSize;
  bool isDownloading = false;
  double downloadProgress = 0;

  _Document({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.uploadedDate,
    required this.fileSize,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _mockDocs = [
  _Document(
      id: 'd1',
      name: 'Offer Letter',
      type: DocType.pdf,
      category: DocCategory.employment,
      uploadedDate: '01 Mar 2024',
      fileSize: '245 KB'),
  _Document(
      id: 'd2',
      name: 'Aadhaar Card',
      type: DocType.pdf,
      category: DocCategory.personal,
      uploadedDate: '10 Mar 2024',
      fileSize: '180 KB'),
  _Document(
      id: 'd3',
      name: 'PAN Card',
      type: DocType.pdf,
      category: DocCategory.personal,
      uploadedDate: '10 Mar 2024',
      fileSize: '120 KB'),
  _Document(
      id: 'd4',
      name: 'Experience Letter',
      type: DocType.pdf,
      category: DocCategory.employment,
      uploadedDate: '12 Mar 2024',
      fileSize: '310 KB'),
  _Document(
      id: 'd5',
      name: 'Bank Account Details',
      type: DocType.pdf,
      category: DocCategory.compliance,
      uploadedDate: '15 Mar 2024',
      fileSize: '95 KB'),
  _Document(
      id: 'd6',
      name: 'Profile Photo',
      type: DocType.image,
      category: DocCategory.personal,
      uploadedDate: '15 Mar 2024',
      fileSize: '450 KB'),
  _Document(
      id: 'd7',
      name: 'Relieving Letter',
      type: DocType.pdf,
      category: DocCategory.employment,
      uploadedDate: '20 Mar 2024',
      fileSize: '198 KB'),
  _Document(
      id: 'd8',
      name: 'POSH Certificate',
      type: DocType.pdf,
      category: DocCategory.compliance,
      uploadedDate: '25 Mar 2024',
      fileSize: '145 KB'),
  _Document(
      id: 'd9',
      name: 'AWS Certificate',
      type: DocType.pdf,
      category: DocCategory.training,
      uploadedDate: '01 Apr 2024',
      fileSize: '290 KB'),
  _Document(
      id: 'd10',
      name: 'Induction Completion',
      type: DocType.pdf,
      category: DocCategory.training,
      uploadedDate: '18 Mar 2024',
      fileSize: '112 KB'),
  _Document(
      id: 'd11',
      name: 'Salary Structure Sheet',
      type: DocType.excel,
      category: DocCategory.compliance,
      uploadedDate: '31 Mar 2024',
      fileSize: '64 KB'),
  _Document(
      id: 'd12',
      name: 'Appointment Letter',
      type: DocType.word,
      category: DocCategory.employment,
      uploadedDate: '15 Mar 2024',
      fileSize: '88 KB'),
];

// ─────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────
const _filterLabels = [
  'All',
  'Personal',
  'Employment',
  'Compliance',
  'Training'
];

const _uploadCategories = ['Personal', 'Employment', 'Compliance', 'Training'];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
({Color color, Color bg, IconData icon, String label}) _docTypeMeta(DocType t) {
  switch (t) {
    case DocType.pdf:
      return (
        color: _C.error,
        bg: _C.errorLight,
        icon: Icons.picture_as_pdf_outlined,
        label: 'PDF'
      );
    case DocType.image:
      return (
        color: _C.primary,
        bg: _C.primaryLight,
        icon: Icons.image_outlined,
        label: 'IMG'
      );
    case DocType.excel:
      return (
        color: _C.success,
        bg: _C.successLight,
        icon: Icons.table_chart_outlined,
        label: 'XLS'
      );
    case DocType.word:
      return (
        color: _C.accent,
        bg: _C.accentLight,
        icon: Icons.description_outlined,
        label: 'DOC'
      );
    case DocType.other:
      return (
        color: _C.textSec,
        bg: _C.surface,
        icon: Icons.insert_drive_file_outlined,
        label: 'FILE'
      );
  }
}

({Color color, Color bg, String label}) _catMeta(DocCategory c) {
  switch (c) {
    case DocCategory.personal:
      return (color: _C.primary, bg: _C.primaryLight, label: 'Personal');
    case DocCategory.employment:
      return (color: _C.teal, bg: _C.tealLight, label: 'Employment');
    case DocCategory.compliance:
      return (color: _C.warning, bg: _C.warningLight, label: 'Compliance');
    case DocCategory.training:
      return (color: _C.accent, bg: _C.accentLight, label: 'Training');
  }
}

DocCategory? _labelToCategory(String label) {
  switch (label) {
    case 'Personal':
      return DocCategory.personal;
    case 'Employment':
      return DocCategory.employment;
    case 'Compliance':
      return DocCategory.compliance;
    case 'Training':
      return DocCategory.training;
    default:
      return null;
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  final List<_Document> _docs = List.from(_mockDocs);
  int _activeFilter = 0;
  final Set<String> _selected = {};
  bool _selectMode = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  // ── Filtered list ────────────────────────────
  List<_Document> get _filtered {
    final catFilter = _labelToCategory(_filterLabels[_activeFilter]);
    return _docs.where((d) {
      final matchesCat = catFilter == null || d.category == catFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  // ── Selection helpers ────────────────────────
  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _selectMode = false;
      } else {
        _selected.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selected.clear();
      _selectMode = false;
    });
  }

  // ── Download ─────────────────────────────────
  Future<void> _download(_Document doc) async {
    setState(() {
      doc.isDownloading = true;
      doc.downloadProgress = 0;
    });
    const total = 30;
    for (int i = 1; i <= total; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() => doc.downloadProgress = i / total);
    }
    setState(() {
      doc.isDownloading = false;
      doc.downloadProgress = 0;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${doc.name} downloaded ✅'),
        backgroundColor: _C.successDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  // ── Delete ────────────────────────────────────
  void _delete(_Document doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Document',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Text('Delete "${doc.name}"? This cannot be undone.',
            style: const TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel', style: TextStyle(color: _C.textSec))),
          TextButton(
            onPressed: () {
              context.pop();
              setState(() => _docs.removeWhere((d) => d.id == doc.id));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Document deleted'),
                backgroundColor: _C.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ));
            },
            child: const Text('Delete',
                style: TextStyle(color: _C.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Show upload sheet ────────────────────────
  void _showUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _UploadSheet(onUploaded: (doc) {
        setState(() => _docs.insert(0, doc));
      }),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      floatingActionButton: _selectMode ? null : _buildFAB(),
      body: Column(children: [
        _buildSearchBar(),
        _buildFilterTabs(),
        _buildSummaryRow(filtered),
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(
                  filterLabel: _filterLabels[_activeFilter],
                  onUpload: _showUploadSheet,
                )
              : _buildDocList(filtered),
        ),
      ]),
    );
  }

  // ── App Bar ──────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    if (_selectMode) {
      return AppBar(
        backgroundColor: _C.primaryDark,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _clearSelection,
        ),
        title: Text('${_selected.length} selected',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Download selected',
            onPressed: () {
              for (final id in _selected) {
                final doc = _docs.firstWhere((d) => d.id == id);
                _download(doc);
              }
              _clearSelection();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete selected',
            onPressed: () {
              setState(() {
                _docs.removeWhere((d) => _selected.contains(d.id));
                _clearSelection();
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      );
    }
    return AppBar(
      backgroundColor: _C.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: _C.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: const Text('Documents',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary)),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort_rounded, size: 22),
          color: _C.textSec,
          onPressed: _showSortSheet,
          tooltip: 'Sort',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list_rounded, size: 22),
          color: _C.textSec,
          onPressed: () {},
          tooltip: 'Filter',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Search bar ───────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: _C.card,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 14, color: _C.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search documents…',
          hintStyle: const TextStyle(fontSize: 14, color: _C.textTert),
          prefixIcon:
              const Icon(Icons.search_rounded, size: 20, color: _C.textTert),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      size: 18, color: _C.textTert),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: _C.surface,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.primary, width: 1.5)),
        ),
      ),
    );
  }

  // ── Filter tabs ──────────────────────────────
  Widget _buildFilterTabs() {
    return Container(
      color: _C.card,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_filterLabels.length, (i) {
            final active = i == _activeFilter;
            final label = _filterLabels[i];
            final count = i == 0
                ? _docs.length
                : _docs
                    .where((d) => d.category == _labelToCategory(label))
                    .length;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeFilter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? _C.primary : _C.surface,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        active ? null : Border.all(color: _C.border, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : _C.textSec)),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withValues(alpha: .25)
                              : _C.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$count',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: active ? Colors.white : _C.textSec)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Summary row ──────────────────────────────
  Widget _buildSummaryRow(List<_Document> filtered) {
    final total = filtered.length;
    final pdfCount = filtered.where((d) => d.type == DocType.pdf).length;
    return Container(
      color: _C.bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        Text('$total document${total != 1 ? "s" : ""}',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: _C.textSec)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: _C.errorLight, borderRadius: BorderRadius.circular(6)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.picture_as_pdf_outlined,
                size: 11, color: _C.error),
            const SizedBox(width: 3),
            Text('$pdfCount PDF${pdfCount != 1 ? "s" : ""}',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _C.error)),
          ]),
        ),
      ]),
    );
  }

  // ── Document list ────────────────────────────
  Widget _buildDocList(List<_Document> docs) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _DocCard(
        doc: docs[i],
        isSelected: _selected.contains(docs[i].id),
        selectMode: _selectMode,
        onTap: () {
          if (_selectMode) {
            _toggleSelect(docs[i].id);
          } else {
            _showDocDetail(docs[i]);
          }
        },
        onLongPress: () {
          setState(() {
            _selectMode = true;
            _selected.add(docs[i].id);
          });
        },
        onDownload: () => _download(docs[i]),
        onDelete: () => _delete(docs[i]),
        onShare: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Sharing — coming soon'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ));
        },
        onView: () => _showDocDetail(docs[i]),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showUploadSheet,
      backgroundColor: _C.primary,
      foregroundColor: Colors.white,
      elevation: 3,
      icon: const Icon(Icons.upload_file_outlined, size: 20),
      label: const Text('Upload',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  // ── Sort sheet ───────────────────────────────
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SortSheet(),
    );
  }

  // ── Doc detail ───────────────────────────────
  void _showDocDetail(_Document doc) {
    final meta = _docTypeMeta(doc.type);
    final cat = _catMeta(doc.category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DocDetailSheet(
          doc: doc, meta: meta, cat: cat, onDownload: () => _download(doc)),
    );
  }
}

// ─────────────────────────────────────────────
// DOCUMENT CARD
// ─────────────────────────────────────────────
class _DocCard extends StatelessWidget {
  final _Document doc;
  final bool isSelected;
  final bool selectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onView;

  const _DocCard({
    required this.doc,
    required this.isSelected,
    required this.selectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onDownload,
    required this.onDelete,
    required this.onShare,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _docTypeMeta(doc.type);
    final cat = _catMeta(doc.category);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _C.primary : _C.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Selection checkbox
                  if (selectMode) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? _C.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? _C.primary : _C.border,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white)
                          : null,
                    ),
                  ],
                  // Type icon box
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: meta.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(meta.icon, color: meta.color, size: 24),
                        Positioned(
                          right: 3,
                          bottom: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: meta.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(meta.label,
                                style: const TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.3)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: cat.bg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(cat.label,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: cat.color)),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.access_time_rounded,
                              size: 11, color: _C.textTert),
                          const SizedBox(width: 3),
                          Text(doc.uploadedDate,
                              style: const TextStyle(
                                  fontSize: 11, color: _C.textTert)),
                          const SizedBox(width: 8),
                          const Icon(Icons.data_usage_rounded,
                              size: 11, color: _C.textTert),
                          const SizedBox(width: 3),
                          Text(doc.fileSize,
                              style: const TextStyle(
                                  fontSize: 11, color: _C.textTert)),
                        ]),
                      ],
                    ),
                  ),
                  // 3-dot menu
                  if (!selectMode)
                    _DocMenu(
                      onView: onView,
                      onDownload: onDownload,
                      onShare: onShare,
                      onDelete: onDelete,
                    ),
                ],
              ),
            ),
            // Download progress bar
            if (doc.isDownloading) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Downloading…',
                            style: TextStyle(
                                fontSize: 11,
                                color: _C.primary,
                                fontWeight: FontWeight.w500)),
                        Text('${(doc.downloadProgress * 100).toInt()}%',
                            style: const TextStyle(
                                fontSize: 11,
                                color: _C.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: doc.downloadProgress,
                        minHeight: 5,
                        backgroundColor: _C.primaryLight,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_C.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 3-DOT MENU
// ─────────────────────────────────────────────
class _DocMenu extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _DocMenu({
    required this.onView,
    required this.onDownload,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 20, color: _C.textSec),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      shadowColor: Colors.black12,
      color: _C.card,
      padding: EdgeInsets.zero,
      onSelected: (val) {
        switch (val) {
          case 'view':
            onView();
            break;
          case 'download':
            onDownload();
            break;
          case 'share':
            onShare();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (_) => [
        _menuItem('view', Icons.visibility_outlined, 'View', _C.textPrimary),
        _menuItem('download', Icons.download_outlined, 'Download', _C.primary),
        _menuItem('share', Icons.share_outlined, 'Share', _C.accent),
        const PopupMenuDivider(height: 1),
        _menuItem('delete', Icons.delete_outline_rounded, 'Delete', _C.error),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
      String val, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: val,
      height: 44,
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filterLabel;
  final VoidCallback onUpload;

  const _EmptyState({required this.filterLabel, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _C.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.folder_open_outlined,
                  size: 42, color: _C.primary),
            ),
            const SizedBox(height: 20),
            Text(
              filterLabel == 'All'
                  ? 'No documents yet'
                  : 'No $filterLabel documents',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              filterLabel == 'All'
                  ? 'Upload your first document to get started'
                  : 'Upload a $filterLabel document to see it here',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, color: _C.textSec, height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: const Text('Upload Now',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.primary,
                side: const BorderSide(color: _C.primary, width: 1.5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPLOAD BOTTOM SHEET
// ─────────────────────────────────────────────
class _UploadSheet extends StatefulWidget {
  final void Function(_Document doc) onUploaded;
  const _UploadSheet({required this.onUploaded});

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  String? _category;
  String _docName = '';
  String _fileName = '';
  bool _uploading = false;
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get _canSubmit =>
      _category != null &&
      _docName.isNotEmpty &&
      _fileName.isNotEmpty &&
      !_uploading;

  void _pickFile() {
    setState(() =>
        _fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _uploading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    final catMap = {
      'Personal': DocCategory.personal,
      'Employment': DocCategory.employment,
      'Compliance': DocCategory.compliance,
      'Training': DocCategory.training,
    };
    final newDoc = _Document(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      name: _docName,
      type: DocType.pdf,
      category: catMap[_category!]!,
      uploadedDate: 'Today',
      fileSize: '—',
    );
    if (mounted) {
      context.pop();
      widget.onUploaded(newDoc);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$_docName uploaded successfully ✅'),
        backgroundColor: _C.successDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 28),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _C.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Upload Document',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(height: 2),
              const Text('Add a new document to your records',
                  style: TextStyle(fontSize: 13, color: _C.textSec)),
              const SizedBox(height: 20),

              // Category
              _sheetLabel('Document Category *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _uploadCategories.map((cat) {
                  final active = _category == cat;
                  final catMeta = _catMeta(_labelToCategory(cat)!);
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? catMeta.color : _C.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? catMeta.color : _C.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(cat,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : _C.textSec)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Doc name
              _sheetLabel('Document Name *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                onChanged: (v) => setState(() => _docName = v),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
                maxLength: 100,
                style: const TextStyle(
                    fontSize: 14,
                    color: _C.textPrimary,
                    fontWeight: FontWeight.w500),
                decoration: _sheetInputDeco('e.g. Offer Letter 2024'),
              ),
              const SizedBox(height: 16),

              // File picker
              _sheetLabel('File *'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _fileName.isNotEmpty ? _C.successLight : _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _fileName.isNotEmpty ? _C.success : _C.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(children: [
                    Icon(
                      _fileName.isNotEmpty
                          ? Icons.check_circle_outline_rounded
                          : Icons.attach_file_rounded,
                      size: 20,
                      color: _fileName.isNotEmpty ? _C.successDark : _C.textSec,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _fileName.isNotEmpty
                            ? _fileName
                            : 'Tap to choose a file (PDF, Image, Excel)',
                        style: TextStyle(
                            fontSize: 13,
                            color: _fileName.isNotEmpty
                                ? _C.successDark
                                : _C.textSec,
                            fontWeight: _fileName.isNotEmpty
                                ? FontWeight.w500
                                : FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_fileName.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _fileName = ''),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: _C.textSec),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              // Upload button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _upload : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    disabledBackgroundColor: _C.border,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _uploading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Upload Document',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DOC DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────
class _DocDetailSheet extends StatelessWidget {
  final _Document doc;
  final ({Color color, Color bg, IconData icon, String label}) meta;
  final ({Color color, Color bg, String label}) cat;
  final VoidCallback onDownload;

  const _DocDetailSheet({
    required this.doc,
    required this.meta,
    required this.cat,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _C.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: meta.bg, borderRadius: BorderRadius.circular(16)),
            child: Icon(meta.icon, color: meta.color, size: 32),
          ),
          const SizedBox(height: 14),
          Text(doc.name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: cat.bg, borderRadius: BorderRadius.circular(20)),
            child: Text(cat.label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cat.color)),
          ),
          const SizedBox(height: 20),
          // Meta grid
          _DetailGrid(items: [
            ('Type', meta.label),
            ('Size', doc.fileSize),
            ('Uploaded', doc.uploadedDate),
            ('Status', 'Verified ✅'),
          ]),
          const SizedBox(height: 20),
          // Action buttons
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.visibility_outlined, size: 17),
                label: const Text('View'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _C.primary,
                  side: const BorderSide(color: _C.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pop();
                  onDownload();
                },
                icon: const Icon(Icons.download_outlined, size: 17),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<(String, String)> items;
  const _DetailGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: _C.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: List.generate(items.length, (i) {
          final (label, value) = items[i];
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 13, color: _C.textSec)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary)),
                ],
              ),
            ),
            if (i < items.length - 1)
              Container(
                  height: 1,
                  color: _C.border,
                  margin: const EdgeInsets.symmetric(horizontal: 16)),
          ]);
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SORT SHEET
// ─────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  final _options = const [
    (Icons.sort_by_alpha_rounded, 'Name (A → Z)'),
    (Icons.calendar_today_outlined, 'Date (Newest first)'),
    (Icons.calendar_today_outlined, 'Date (Oldest first)'),
    (Icons.data_usage_rounded, 'File size (Large first)'),
    (Icons.category_outlined, 'Category'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _C.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Sort Documents',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary)),
          const SizedBox(height: 14),
          ..._options.map((opt) {
            final (icon, label) = opt;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: _C.primary),
              ),
              title: Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _C.textPrimary)),
              onTap: () => context.pop(),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────
Widget _sheetLabel(String text) => Text(text,
    style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: _C.textPrimary));

InputDecoration _sheetInputDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: _C.textTert),
      filled: true,
      fillColor: _C.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.border, width: 1.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.border, width: 1.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.error, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.error, width: 1.5)),
      counterStyle: const TextStyle(fontSize: 11, color: _C.textTert),
      errorStyle: const TextStyle(fontSize: 11, color: _C.error),
    );
