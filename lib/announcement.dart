import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementForm extends StatefulWidget {
  const AnnouncementForm({super.key});

  @override
  State<AnnouncementForm> createState() => _AnnouncementFormState();
}

class _AnnouncementFormState extends State<AnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  File? _imageFile;
  File? _pdfFile;
  String _announcementType = 'text_only';
  final List<String> _targetAudience = ['all'];
  bool _isPinned = false;

  final List<String> audienceOptions = [
    'all',
    'praise_team',
    'bible_study',
    'ushering'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() => _pdfFile = File(result.files.single.path!));
    }
  }

  Future<void> _uploadAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl, pdfUrl;

    if (_imageFile != null) {
      imageUrl = await uploadImage(_imageFile!);
    }

    if (_pdfFile != null) {
      pdfUrl = await uploadPDF(_pdfFile!);
    }

    await FirebaseFirestore.instance.collection('announcements').add({
      'title': _titleController.text,
      'description': _descController.text,
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'authorId': FirebaseAuth.instance.currentUser?.uid ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'isPinned': _isPinned,
      'targetAudience': _targetAudience,
      'type': _announcementType,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement published!')),
    );
    Navigator.pop(context);
  }

  Future<String?> uploadImage(File imageFile) async {
    final ref = FirebaseStorage.instance
        .ref('announcements/${DateTime.now().millisecondsSinceEpoch}_image.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<String?> uploadPDF(File pdfFile) async {
    final ref = FirebaseStorage.instance
        .ref('announcements/${DateTime.now().millisecondsSinceEpoch}_poster.pdf');
    await ref.putFile(pdfFile);
    return await ref.getDownloadURL();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publish Announcement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _announcementType,
                items: const [
                  DropdownMenuItem(value: 'text_only', child: Text('Text Only')),
                  DropdownMenuItem(value: 'image_text', child: Text('Image + Text')),
                  DropdownMenuItem(value: 'pdf', child: Text('PDF Poster')),
                ],
                onChanged: (value) => setState(() => _announcementType = value!),
                decoration: const InputDecoration(labelText: 'Announcement Type'),
              ),
              const SizedBox(height: 8),
              if (_announcementType == 'image_text') ...[
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text(_imageFile == null ? 'Select Image' : 'Image Selected'),
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Image.file(_imageFile!, height: 100),
                  ),
              ],
              if (_announcementType == 'pdf') ...[
                ElevatedButton(
                  onPressed: _pickPDF,
                  child: Text(_pdfFile == null ? 'Select PDF' : 'PDF Selected'),
                ),
                if (_pdfFile != null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('PDF ready for upload'),
                  ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: audienceOptions.map((option) {
                  return FilterChip(
                    label: Text(option),
                    selected: _targetAudience.contains(option),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _targetAudience.add(option)
                            : _targetAudience.remove(option);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Pin to top'),
                value: _isPinned,
                onChanged: (v) => setState(() => _isPinned = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadAnnouncement,
                child: const Text('Publish Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// User-facing announcement display
class AnnouncementViewPage extends StatelessWidget {
  const AnnouncementViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No announcements yet.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final ann = docs[i].data() as Map<String, dynamic>;
              return AnnouncementCard(ann: ann);
            },
          );
        },
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> ann;
  const AnnouncementCard({super.key, required this.ann});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ann['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (ann['isPinned'] == true)
              const Text('📌 Pinned', style: TextStyle(color: Colors.orange)),
            const SizedBox(height: 4),
            Text(ann['description'] ?? ''),
            if (ann['imageUrl'] != null && ann['imageUrl'] != '')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(ann['imageUrl'], height: 120),
              ),
            if (ann['pdfUrl'] != null && ann['pdfUrl'] != '')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextButton(
                  child: const Text('View Poster (PDF)'),
                  onPressed: () async {
                    final url = ann['pdfUrl'];
                    if (url != null && url.isNotEmpty) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            Text(
              'Audience: ${ann['targetAudience']?.join(', ') ?? 'all'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Posted: ${ann['createdAt'] != null ? ann['createdAt'].toDate().toString().substring(0, 16) : ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminAnnouncementGate()),
                );
              },
              child: const Text('Add Announcement'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnnouncementViewPage()),
                );
              },
              child: const Text('Manage Announcements'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminAnnouncementGate extends StatelessWidget {
  const AdminAnnouncementGate({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in.')),
      );
    }
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User not found.')),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        if (data['role'] == 'admin') {
          return const AnnouncementForm();
        } else {
          return const Scaffold(
            body: Center(child: Text('Access denied. Admins only.')),
          );
        }
      },
    );
  }
}

class AnnouncementTabsPage extends StatelessWidget {
  const AnnouncementTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in.')),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User not found.')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final isAdmin = data['role'] == 'admin';

        return DefaultTabController(
          length: isAdmin ? 2 : 1,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Announcements'),
              bottom: TabBar(
                tabs: [
                  const Tab(text: 'All Announcements', icon: Icon(Icons.list)),
                  if (isAdmin)
                    const Tab(text: 'Add Announcement', icon: Icon(Icons.add)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                const AnnouncementViewPage(),
                if (isAdmin) const AnnouncementForm(),
              ],
            ),
          ),
        );
      },
    );
  }
}
