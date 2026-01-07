import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/localization_service.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCreating = false;
  String _roomType = 'now'; // 'now' or 'reserved'

  Future<void> _createRoom() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _isCreating = true);

    try {
      final roomId = FirebaseDatabase.instance.ref('rooms').push().key;
      await FirebaseDatabase.instance.ref('rooms/$roomId').set({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _roomType,
        'createdAt': ServerValue.timestamp,
        'participants': [],
        'status': _roomType == 'now' ? 'active' : 'pending',
        'host': 'Helper', // Placeholder, ideally get from user profile
        'hostId': 'current_user_id', // Replace with actual user ID
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService().translate('create_room'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService().translate('room_title'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: LocalizationService().translate('enter_room_title'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LocalizationService().translate('description'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: LocalizationService().translate('enter_description'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              LocalizationService().translate('room_type'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(LocalizationService().translate('now')),
                    value: 'now',
                    groupValue: _roomType,
                    onChanged: (value) => setState(() => _roomType = value!),
                    activeColor: const Color(0xFF059669),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(LocalizationService().translate('reserved')),
                    value: 'reserved',
                    groupValue: _roomType,
                    onChanged: (value) => setState(() => _roomType = value!),
                    activeColor: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        LocalizationService().translate('create'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
