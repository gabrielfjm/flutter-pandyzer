import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_pandyzer/core/app_colors.dart';

// DTOs para Comunicação com o Backend
class ChatbotPromptDTO {
  final String prompt;
  ChatbotPromptDTO({required this.prompt});
  Map<String, dynamic> toJson() => {'prompt': prompt};
}

class ChatbotResponseDTO {
  final String response;
  ChatbotResponseDTO({required this.response});
  factory ChatbotResponseDTO.fromJson(Map<String, dynamic> json) =>
      ChatbotResponseDTO(response: json['response'] ?? '');
}

// Serviço de Chatbot
class ChatbotService {
  static const String _baseUrl = 'https://panda-microservice-f3d5adc8dxewfub8.brazilsouth-01.azurewebsites.net';

  static Future<String> getResponseFromBackend(String prompt) async {
    try {
      final requestDto = ChatbotPromptDTO(prompt: prompt);
      final response = await http.post(
        Uri.parse('$_baseUrl/chatbot'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestDto.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final responseDto = ChatbotResponseDTO.fromJson(responseData);
        return responseDto.response;
      } else {
        return "Desculpe, não consegui me conectar ao serviço. Erro: ${response.statusCode}.";
      }
    } catch (e) {
      return "Ocorreu um erro ao tentar me comunicar com o servidor. Verifique se o backend está rodando. Erro: $e";
    }
  }
}

// Modelo de dados para a UI
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

/// Um painel lateral que contém a interface de chat.
/// Este widget agora é controlado por seu pai.
class ChatbotPanel extends StatefulWidget {
  final VoidCallback onClose;
  final List<ChatMessage> messages;
  final Future<void> Function(String) onSendMessage;
  final bool isLoading;

  const ChatbotPanel({
    super.key,
    required this.onClose,
    required this.messages,
    required this.onSendMessage,
    required this.isLoading,
  });

  @override
  State<ChatbotPanel> createState() => _ChatbotPanelState();
}

class _ChatbotPanelState extends State<ChatbotPanel> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ChatbotPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se a lista de mensagens mudar, rola para o final.
    if (widget.messages.length != oldWidget.messages.length) {
      _scrollToBottom();
    }
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

  /// Apenas chama a função do pai para enviar a mensagem.
  void _handleSend() {
    if (_controller.text.trim().isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Card(
        elevation: 10,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Assistente de Usabilidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    tooltip: 'Fechar Assistente',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.messages.length,
                itemBuilder: (context, index) {
                  final message = widget.messages[index];
                  return _ChatMessageBubble(message: message);
                },
              ),
            ),
            if (widget.isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12)
                      ),
                      onSubmitted: (value) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    // O botão é desabilitado com base no estado de `isLoading` vindo do pai.
                    onPressed: widget.isLoading ? null : _handleSend,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.grey900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.grey800 : AppColors.grey200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
