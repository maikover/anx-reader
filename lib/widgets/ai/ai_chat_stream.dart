import 'dart:async';

import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:cubebook/enums/hint_key.dart';
import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/main.dart';
import 'package:cubebook/models/ai_provider.dart';
import 'package:cubebook/providers/ai_chat.dart';
import 'package:cubebook/providers/ai_history.dart';
import 'package:cubebook/providers/ai_providers.dart';
import 'package:cubebook/service/ai/ai_services.dart';
import 'package:cubebook/service/ai/ai_history.dart';
import 'package:cubebook/service/ai/index.dart';
import 'package:cubebook/utils/env_var.dart';
import 'package:cubebook/utils/toast/common.dart';
import 'package:cubebook/utils/ai_reasoning_parser.dart';
import 'package:cubebook/page/settings_page/ai_settings_page.dart';
import 'package:cubebook/widgets/ai/tool_step_tile.dart';
import 'package:cubebook/widgets/ai/tool_tiles/apply_book_tags_step_tile.dart';
import 'package:cubebook/widgets/ai/tool_tiles/mindmap_step_tile.dart';
import 'package:cubebook/widgets/ai/tool_tiles/organize_bookshelf_step_tile.dart';
import 'package:cubebook/widgets/common/anx_button.dart';
import 'package:cubebook/widgets/common/container/filled_container.dart';
import 'package:cubebook/widgets/delete_confirm.dart';
import 'package:cubebook/widgets/markdown/styled_markdown.dart';
import 'package:cubebook/widgets/neo/neo_background.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:langchain_core/chat_models.dart';

import 'package:cubebook/models/ai_quick_prompt_chip.dart';

class AiChatStream extends ConsumerStatefulWidget {
  const AiChatStream({
    super.key,
    this.initialMessage,
    this.sendImmediate = false,
    this.quickPromptChips = const [],
    this.trailing,
  });

  final String? initialMessage;
  final bool sendImmediate;
  final List<AiQuickPromptChip> quickPromptChips;
  final List<Widget>? trailing;

  @override
  ConsumerState<AiChatStream> createState() => AiChatStreamState();
}

class AiChatStreamState extends ConsumerState<AiChatStream> {
  final TextEditingController inputController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<List<ChatMessage>>? _messageStream;
  StreamController<List<ChatMessage>>? _messageController;
  StreamSubscription<List<ChatMessage>>? _messageSubscription;
  final ScrollController _scrollController = ScrollController();
  bool _isStreaming = false;
  late List<String> _suggestedPrompts;
  late List<String> _starterPrompts;
  double _fontSize = 14.0;

  List<Map<String, String>> _getQuickPrompts(BuildContext context) {
    return [
      {
        'label': L10n.of(context).aiQuickPromptExplain,
        'prompt': L10n.of(context).aiQuickPromptExplainText,
      },
      {
        'label': L10n.of(context).aiQuickPromptOpinion,
        'prompt': L10n.of(context).aiQuickPromptOpinionText,
      },
      {
        'label': L10n.of(context).aiQuickPromptSummary,
        'prompt': L10n.of(context).aiQuickPromptSummaryText,
      },
      {
        'label': L10n.of(context).aiQuickPromptAnalyze,
        'prompt': L10n.of(context).aiQuickPromptAnalyzeText,
      },
      {
        'label': L10n.of(context).aiQuickPromptSuggest,
        'prompt': L10n.of(context).aiQuickPromptSuggestText,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _starterPrompts = [
      L10n.of(navigatorKey.currentContext!).quickPrompt1,
      L10n.of(navigatorKey.currentContext!).quickPrompt2,
      L10n.of(navigatorKey.currentContext!).quickPrompt3,
      L10n.of(navigatorKey.currentContext!).quickPrompt4,
      L10n.of(navigatorKey.currentContext!).quickPrompt5,
      L10n.of(navigatorKey.currentContext!).quickPrompt6,
      L10n.of(navigatorKey.currentContext!).quickPrompt7,
      L10n.of(navigatorKey.currentContext!).quickPrompt8,
      L10n.of(navigatorKey.currentContext!).quickPrompt9,
      L10n.of(navigatorKey.currentContext!).quickPrompt10,
      L10n.of(navigatorKey.currentContext!).quickPrompt11,
      L10n.of(navigatorKey.currentContext!).quickPrompt12,
    ];
    _fontSize = Prefs().aiChatFontSize;
    inputController.text = widget.initialMessage ?? '';
    _suggestedPrompts = _pickSuggestedPrompts();
    if (widget.sendImmediate) {
      _sendMessage();
    }
    _scrollToBottom();
  }

  @override
  void dispose() {
    inputController.dispose();
    _messageSubscription?.cancel();
    _messageController?.close();
    _scrollController.dispose();
    super.dispose();
  }

  AiProvider? _currentProvider(List<AiProvider> enabledProviders) {
    final selectedId = Prefs().selectedAiService;
    try {
      return enabledProviders.firstWhere((p) => p.id == selectedId);
    } catch (_) {
      return enabledProviders.isNotEmpty ? enabledProviders.first : null;
    }
  }

  String _modelLabel(AiProvider provider) {
    final model = provider.model;
    if (model.trim().isNotEmpty) return model;
    // Fallback: look up default model from built-in templates
    final defaults = buildDefaultAiServices();
    for (final d in defaults) {
      if (d.identifier == provider.id) return d.defaultModel;
    }
    return '';
  }

  void _onProviderSelected(String providerId) {
    if (_isStreaming) return;
    ref.read(aiProvidersProvider.notifier).setSelectedProvider(providerId);
  }

  AiProvider? _providerById(List<AiProvider> providers, String id) {
    for (final p in providers) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<String> _pickSuggestedPrompts() {
    final prompts = List<String>.from(_starterPrompts)..shuffle();
    return prompts.take(3).toList(growable: false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildHistoryDrawer(BuildContext context) {
    final historyState = ref.watch(aiHistoryProvider);
    return SafeArea(
      child: Column(
        children: [
          ListTile(
            title: Text(L10n.of(context).conversationHistory),
            trailing: DeleteConfirm(
              delete: () => _confirmClearHistory(context),
              deleteIcon: Icon(Icons.delete_sweep),
            ),
          ),
          Expanded(
            child: historyState.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(L10n.of(context).noConversationTip),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final entry = items[index];
                    return _buildHistoryTile(context, entry);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(L10n.of(context).failedToLoadHistoryTip),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, AiChatHistoryEntry entry) {
    final allProviders = ref.watch(aiProvidersProvider);
    final provider = _providerById(allProviders, entry.serviceId);
    final statusColor =
        entry.completed ? Colors.green : Theme.of(context).colorScheme.tertiary;
    final title = _deriveTitle(entry);
    final subtitle = _buildHistorySubtitle(provider, entry);

    return FilledContainer(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(8),
      useNeoStyle: true,
      child: GestureDetector(
        onTap: () => _handleHistoryTap(context, entry),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      _formatTimestamp(entry.updatedAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 10, color: statusColor),
                    DeleteConfirm(
                        delete: () => _confirmDeleteHistory(context, entry)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildHistorySubtitle(AiProvider? provider, AiChatHistoryEntry entry) {
    final serviceLabel = provider?.title ?? entry.serviceId;
    if (entry.model.isEmpty) {
      return serviceLabel;
    }
    return '$serviceLabel · ${entry.model}';
  }

  Widget? _providerLogo(AiProvider? provider) {
    final logo = provider?.logoAsset;
    if (logo == null || logo.isEmpty) return null;
    return Image.asset(
      logo,
      width: 20,
      height: 20,
      errorBuilder: (_, __, ___) => const SizedBox(),
    );
  }

  String _deriveTitle(AiChatHistoryEntry entry) {
    for (final message in entry.messages) {
      if (message is HumanChatMessage) {
        final content = message.contentAsString.trim();
        if (content.isNotEmpty) {
          final firstLine = content.split('\n').first.trim();
          return firstLine;
        }
      }
    }
    if (entry.messages.isNotEmpty) {
      return 'Conversation';
    }
    return 'Empty conversation';
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final date =
        '${dateTime.year}-${twoDigits(dateTime.month)}-${twoDigits(dateTime.day)}';
    final time = '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
    return '$date $time';
  }

  Future<void> _handleHistoryTap(
    BuildContext context,
    AiChatHistoryEntry entry,
  ) async {
    if (_isStreaming) {
      _cancelStreaming();
    }
    _messageSubscription?.cancel();
    _messageSubscription = null;
    final controller = _messageController;
    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
    _messageController = null;

    ref.read(aiChatProvider.notifier).loadHistoryEntry(entry);

    setState(() {
      _messageStream = null;
      // reset state when switching service
    });

    Navigator.of(context).pop();
    _scrollToBottom();
  }

  Future<void> _confirmDeleteHistory(
    BuildContext context,
    AiChatHistoryEntry entry,
  ) async {
    await ref.read(aiHistoryProvider.notifier).remove(entry.id);

    final currentSessionId = ref.read(aiChatProvider.notifier).currentSessionId;
    if (currentSessionId == entry.id) {
      ref.read(aiChatProvider.notifier).clear();
      setState(() {
        _messageStream = null;
        // reset state when conversation changes
      });
    }
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    await ref.read(aiHistoryProvider.notifier).clear();
    ref.read(aiChatProvider.notifier).clear();
    setState(() {
      _messageStream = null;
    });
  }

  void _sendMessage({bool isRegenerate = false}) {
    if (_isStreaming) {
      return;
    }

    if (inputController.text.trim().isEmpty) return;
    final message = inputController.text.trim();
    inputController.clear();

    _messageSubscription?.cancel();
    _messageController?.close();

    final controller = StreamController<List<ChatMessage>>();
    final stream = ref.read(aiChatProvider.notifier).sendMessageStream(
          message,
          ref,
          isRegenerate,
        );

    setState(() {
      _messageController = controller;
      _messageStream = controller.stream;
      _isStreaming = true;
    });

    _messageSubscription = stream.listen(
      (event) {
        controller.add(event);
        _scrollToBottom();
      },
      onError: (error, stack) {
        controller.addError(error, stack);
        if (!controller.isClosed) {
          controller.close();
        }
        if (mounted) {
          setState(() {
            _isStreaming = false;
          });
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
        if (mounted) {
          setState(() {
            _isStreaming = false;
          });
        }
      },
      cancelOnError: false,
    );
  }

  void _useQuickPrompt(String prompt) {
    inputController.text = '$prompt ${inputController.text}';
    _sendMessage();
  }

  void _clearMessage() {
    if (_isStreaming) {
      return;
    }
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _messageController?.close();
    _messageController = null;
    setState(() {
      ref.read(aiChatProvider.notifier).clear();
      _messageStream = null;
      _suggestedPrompts = _pickSuggestedPrompts();
    });
  }

  void _regenerateLastMessage() {
    if (_isStreaming) {
      return;
    }
    final messages = ref.read(aiChatProvider).value;
    if (messages == null || messages.isEmpty) {
      return;
    }

    for (int i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      if (message is HumanChatMessage) {
        final history = messages.take(i).toList(growable: false);
        ref.read(aiChatProvider.notifier).restore(history);
        setState(() {
          inputController.text = message.contentAsString;
          _sendMessage(isRegenerate: true);
        });
        break;
      }
    }
  }

  void _copyMessageContent(String content) {
    final parsed = parseReasoningContent(content);
    final clipboardText = _buildCopyableText(parsed, content);
    Clipboard.setData(ClipboardData(text: clipboardText));
    AnxToast.show(L10n.of(context).notesPageCopied);
  }

  void _cancelStreaming() {
    if (!_isStreaming) return;
    cancelActiveAiRequest();
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _messageController?.close();
    _messageController = null;
    setState(() {
      _isStreaming = false;
      _messageStream = null;
    });
  }

  void _showFontSizeMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 1,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: StatefulBuilder(
            builder: (context, setMenuState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    L10n.of(context).aiChatFontSize,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      Text(
                        '${_fontSize.round()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 10.0,
                          max: 24.0,
                          divisions: 14,
                          onChanged: (value) {
                            setMenuState(() {});
                            setState(() {
                              _fontSize = value;
                            });
                            Prefs().aiChatFontSize = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  ChatMessage? _getLastAssistantMessage() {
    final messages = ref.watch(aiChatProvider).asData?.value;
    if (messages == null || messages.isEmpty) {
      return null;
    }

    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i] is AIChatMessage) {
        return messages[i];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final quickPrompts = _getQuickPrompts(context);
    final allProviders = ref.watch(aiProvidersProvider);
    final enabledProviders = allProviders.where((p) => p.enabled).toList();
    final currentProvider = _currentProvider(enabledProviders);
    final selectedId = Prefs().selectedAiService;

    var aiService = PopupMenuButton<String>(
      enabled: !_isStreaming,
      onSelected: _onProviderSelected,
      itemBuilder: (context) {
        return enabledProviders.map((provider) {
          final isSelected = provider.id == selectedId;
          final label = _modelLabel(provider);
          final logo = _providerLogo(provider);
          return PopupMenuItem<String>(
            value: provider.id,
            child: Row(
              children: [
                if (logo != null) logo else const SizedBox(width: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label.isNotEmpty
                        ? '${provider.title} · $label'
                        : provider.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) const Icon(Icons.check, size: 16),
              ],
            ),
          );
        }).toList(growable: false);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_providerLogo(currentProvider) != null)
            _providerLogo(currentProvider)!,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              currentProvider != null
                  ? () {
                      final label = _modelLabel(currentProvider);
                      return label.isNotEmpty
                          ? '${currentProvider.title} · $label'
                          : currentProvider.title;
                    }()
                  : '',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, size: 16),
        ],
      ),
    );
    Widget sendButton = NeoIconButton(
      icon: _isStreaming ? Icons.stop : Icons.send,
      onPressed: _isStreaming ? _cancelStreaming : _sendMessage,
      size: 40,
      color: NeoBrutalColors.red,
      iconColor: NeoBrutalColors.white,
    );

    Widget inputBox = FilledContainer(
      padding: const EdgeInsets.all(8),
      useNeoStyle: true,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      spacing: 8,
                      children: quickPrompts.map((prompt) {
                        return NeoFilterChip(
                          label: prompt['label']!,
                          selected: false,
                          onTap: () => _useQuickPrompt(prompt['prompt']!),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextField(
              controller: inputController,
              decoration: InputDecoration(
                isDense: true,
                hintText: L10n.of(context).aiHintInputPlaceholder,
                border: InputBorder.none,
              ),
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(child: aiService),
                      if (currentProvider != null)
                        NeoIconButton(
                          icon: Icons.tune,
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const AiSettingsPage(),
                              ),
                            );
                          },
                          size: 40,
                        ),
                    ],
                  ),
                ),
                sendButton,
              ],
            ),
          ],
        ),
      ),
    );

    Widget buildEmptyState() {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      Widget buildQuickChipColumn() {
        if (widget.quickPromptChips.isEmpty) {
          return const SizedBox.shrink();
        }

        final chips = <Widget>[];
        for (var i = 0; i < widget.quickPromptChips.length; i++) {
          final chip = widget.quickPromptChips[i];
          chips.add(
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8.0),
              child: NeoFilterChip(
                label: chip.label,
                selected: false,
                onTap: () {
                  inputController.text = chip.prompt;
                  _sendMessage();
                },
              ),
            ),
          );
        }

        return Positioned(
          right: 16,
          bottom: 16,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: SingleChildScrollView(
              // scrollDirection: Axis.horizontal,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: chips,
              ),
            ),
          ),
        );
      }

      return Stack(
        children: [
          if (widget.quickPromptChips.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NeoBrutalColors.cardColor(isDark),
                  border: Border.all(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                  boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      L10n.of(context).tryAQuickPrompt,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestedPrompts
                          .map(
                            (prompt) => NeoFilterChip(
                              label: prompt,
                              selected: false,
                              onTap: () {
                                inputController.text = prompt;
                                _sendMessage();
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
            ),
          buildQuickChipColumn(),
        ],
      );
    }

    return NeoBackground(
      pattern: NeoBackgroundPattern.grid,
      opacity: 0.03,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: NeoIconButton(
            icon: Icons.menu,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            size: 32,
          ),
        ),
        title: Text(
          L10n.of(context).aiChat,
          style: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          const SizedBox(width: 8),
          NeoIconButton(
            icon: Icons.add,
            onPressed: _clearMessage,
            size: 32,
          ),
          const SizedBox(width: 8),
          NeoIconButton(
            icon: Icons.more_vert,
            onPressed: () => _showFontSizeMenu(context),
            size: 32,
          ),
          const SizedBox(width: 8),
          if (widget.trailing != null) ...widget.trailing!,
        ],
      ),
      drawer: Drawer(
        child: _buildHistoryDrawer(context),
      ),
      body: EnvVar.isAppStore &&
              Prefs().shouldShowHint(HintKey.aiDataSharingConsent)
          ? _buildDataSharingConsent(context)
          : Column(
              children: [
                Expanded(
                  child: _messageStream != null
                      ? StreamBuilder<List<ChatMessage>>(
                          stream: _messageStream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Skeletonizer.zone(child: Bone.multiText());
                            }

                            final messages = snapshot.data!;
                            if (messages.isEmpty) {
                              return buildEmptyState();
                            }

                            return _buildMessageList(messages);
                          },
                        )
                      : ref.watch(aiChatProvider).when(
                            data: (messages) {
                              if (messages.isEmpty) {
                                return buildEmptyState();
                              }

                              return _buildMessageList(messages);
                            },
                            loading: () =>
                                Skeletonizer.zone(child: Bone.multiText()),
                            error: (error, stack) =>
                                Center(child: Text('error: $error')),
                          ),
                ),
                inputBox,
              ],
            ),
      ),
    );
  }

  Widget _buildDataSharingConsent(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.9;
    final constrainedWidth = maxWidth > 500 ? 500.0 : maxWidth;

    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constrainedWidth),
            child: FilledContainer(
              padding: const EdgeInsets.all(24),
              radius: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    L10n.of(context).aiDataSharingTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    L10n.of(context).aiDataSharingContent,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AnxButton(
                    onPressed: () {
                      Prefs().setShowHint(HintKey.aiDataSharingConsent, false);
                      setState(() {});
                    },
                    child: Text(L10n.of(context).aiDataSharingAgree),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isStreaming =
            _messageStream != null && index == messages.length - 1;
        return _buildMessageItem(message, index, isStreaming);
      },
    );
  }

  Widget _buildMessageItem(
    ChatMessage message,
    int index,
    bool isStreaming,
  ) {
    final isUser = message is HumanChatMessage;
    final content = chatMessageDisplayContent(message);
    final parsed = parseReasoningContent(content);
    final isLongMessage = content.length > 300;
    final lastAssistantMessage = _getLastAssistantMessage();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 8.0,
        left: isUser ? 8.0 : 0,
        right: isUser ? 0 : 8.0,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? NeoBrutalColors.adaptiveYellow(isDark)
                    : NeoBrutalColors.cardColor(isDark),
                border: Border.all(
                  width: 4,
                  color: NeoBrutalColors.borderColor(isDark),
                ),
                boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isUser
                      ? _buildCollapsibleText(content, isLongMessage)
                      : _buildAssistantTimeline(parsed, isStreaming),
                  if (!isUser)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (identical(message, lastAssistantMessage))
                            _buildNeoTextButton(
                              L10n.of(context).aiRegenerate,
                              _regenerateLastMessage,
                            ),
                          _buildNeoTextButton(
                            L10n.of(context).commonCopy,
                            () => _copyMessageContent(content),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildNeoTextButton(String text, VoidCallback onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: NeoBrutalColors.cardColor(isDark),
            border: Border.all(width: 2, color: NeoBrutalColors.borderColor(isDark)),
          ),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: NeoBrutalColors.borderColor(isDark),
            ),
          ),
        ),
      ),
    );
  }

  String _buildCopyableText(ParsedReasoning parsed, String fallback) {
    final buffer = StringBuffer();
    var hasWrittenSection = false;

    void startSection() {
      if (hasWrittenSection) {
        buffer.writeln();
      } else {
        hasWrittenSection = true;
      }
    }

    // void appendField(String label, String? value) {
    //   final trimmed = value?.trim();
    //   if (trimmed != null && trimmed.isNotEmpty) {
    //     buffer.writeln('$label: $trimmed');
    //   }
    // }

    for (final entry in parsed.timeline) {
      switch (entry.type) {
        case ParsedReasoningEntryType.reply:
          final text = entry.text?.trim();
          if (text != null && text.isNotEmpty) {
            startSection();
            buffer.writeln(text);
          }
          break;
        case ParsedReasoningEntryType.tool:
          // final step = entry.toolStep;
          // if (step != null) {
          //   startSection();
          //   buffer.writeln('[${step.name} (${step.status})]');
          //   appendField('Input', step.input);
          //   appendField('Output', step.output);
          //   appendField('Error', step.error);
          // }
          break;
      }
    }

    final copyText = buffer.toString().trimRight();
    if (copyText.isEmpty) {
      return fallback;
    }
    return copyText;
  }

  Widget _buildAssistantTimeline(ParsedReasoning parsed, bool isStreaming) {
    if (parsed.timeline.isEmpty) {
      return isStreaming
          ? Skeletonizer.zone(child: Bone.multiText())
          : const SizedBox.shrink();
    }

    final reasoningWidgets = _buildTimelineWidgets(
      parsed.reasoningTimeline,
      fontSize: (_fontSize - 1).clamp(11.0, _fontSize).toDouble(),
    );
    final answerWidgets = _buildTimelineWidgets(
      parsed.answerTimeline,
      fontSize: _fontSize,
    );
    final widgets = <Widget>[];

    if (reasoningWidgets.isNotEmpty) {
      widgets.add(_buildThinkingPanel(reasoningWidgets));
    }
    if (answerWidgets.isNotEmpty) {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: 8));
      }
      widgets.addAll(answerWidgets);
    } else if (widgets.isEmpty && isStreaming) {
      widgets.add(Skeletonizer.zone(child: Bone.multiText()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<Widget> _buildTimelineWidgets(
    List<ParsedReasoningEntry> timeline, {
    required double fontSize,
  }) {
    final widgets = <Widget>[];
    for (var i = 0; i < timeline.length; i++) {
      final entry = timeline[i];
      switch (entry.type) {
        case ParsedReasoningEntryType.reply:
          if (entry.text != null && entry.text!.trim().isNotEmpty) {
            widgets.add(
              StyledMarkdown(
                data: entry.text!,
                selectable: true,
                fontSize: fontSize,
              ),
            );
          }
          break;
        case ParsedReasoningEntryType.tool:
          if (entry.toolStep != null) {
            widgets.add(_buildToolTile(entry.toolStep!));
          }
          break;
      }

      if (i != timeline.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }
    return widgets;
  }

  Widget _buildThinkingPanel(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = NeoBrutalColors.borderColor(isDark);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        dense: true,
        visualDensity: VisualDensity.compact,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.fromLTRB(28, 2, 0, 8),
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: borderColor,
        collapsedIconColor: borderColor,
        leading: Icon(
          Icons.psychology_alt_outlined,
          size: 15,
          color: borderColor,
        ),
        title: Text(
          L10n.of(context).aiThinkingHint,
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: borderColor,
          ),
        ),
        children: [
          Container(
            margin: const EdgeInsets.only(left: 7),
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: borderColor,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolTile(ParsedToolStep step) {
    if (step.name == 'bookshelf_organize') {
      return OrganizeBookshelfStepTile(step: step);
    }
    if (step.name == 'mindmap_draw') {
      return MindmapStepTile(step: step);
    }
    if (step.name == 'apply_book_tags') {
      return ApplyBookTagsStepTile(step: step);
    }
    return ToolStepTile(step: step);
  }

  Widget _buildCollapsibleText(String text, bool isLongMessage) {
    if (!isLongMessage) {
      return SelectableText(
        text,
        style: TextStyle(fontSize: _fontSize),
        selectionControls: MaterialTextSelectionControls(),
      );
    }

    return _CollapsibleText(text: text, fontSize: _fontSize);
  }
}

class _CollapsibleText extends StatefulWidget {
  const _CollapsibleText({required this.text, this.fontSize = 14.0});

  final String text;
  final double fontSize;

  @override
  State<_CollapsibleText> createState() => _CollapsibleTextState();
}

class _CollapsibleTextState extends State<_CollapsibleText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = NeoBrutalColors.borderColor(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isExpanded)
          SelectableText(
            widget.text,
            style: TextStyle(fontSize: widget.fontSize, color: borderColor),
            selectionControls: MaterialTextSelectionControls(),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                widget.text.substring(0, 300.clamp(0, widget.text.length)),
                style: TextStyle(fontSize: widget.fontSize, color: borderColor),
                selectionControls: MaterialTextSelectionControls(),
              ),
              Container(
                height: 4,
                color: borderColor,
              ),
            ],
          ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              _isExpanded
                  ? L10n.of(context).aiHintCollapse
                  : L10n.of(context).aiHintExpand,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: borderColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
