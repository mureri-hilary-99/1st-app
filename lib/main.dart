import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCoBrab5Z41319g9f-EY0eRcvWC7e7nvds',
      authDomain: 'kibucu-hila.firebaseapp.com',
      projectId: 'kibucu-hila',
      storageBucket: 'kibucu-hila.firebasestorage.app',
      messagingSenderId: '28785723116',
      appId: '1:28785723116:web:f260754c3d28ce73cfc7c9',
      measurementId: 'G-JVM69SQ9N0', // Optional
    ),
  );
  runApp(const KibuCUApp());
}

class KibuCUApp extends StatelessWidget {
  const KibuCUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kibabii University Christian Union',
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        scaffoldBackgroundColor: const Color(0xFFE6F0FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF003366),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFFCB900),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color.fromARGB(255, 12, 0, 102)),
          bodyLarge: TextStyle(color: Color(0xFF003366)),
          titleLarge: TextStyle(color: Color(0xFF003366)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003366),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

  

// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // If admin, navigate to AdminHomePage, else HomeScreen
        if (email == 'murerihilary21@gmail.com') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminHomePage()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() => _error = e.message ?? 'Login failed');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sign Up Page
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  Future<void> _createUserDocument(String uid, String name, String role, List<String> departments, bool isLeader) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'role': role,
      'departments': departments,
      'is_leader': isLeader,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      );
                      // Create Firestore user document
                      await _createUserDocument(
                        userCredential.user!.uid,
                        'John Mwangi', // Replace with actual name input
                        'leader_praise_worship', // Replace with actual role input
                        ['praise_worship', 'welfare'], // Replace with actual departments input
                        true, // Replace with actual isLeader input
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account created! Please login.')),
                      );
                      Navigator.of(context).pop();
                    } on FirebaseAuthException catch (e) {
                      setState(() => _error = e.message ?? 'Sign up failed');
                    }
                  }
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Home Page (simple placeholder)
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  // Helper to generate CSV from a list of maps
  String _generateCsv(List<Map<String, dynamic>> data, List<String> fields) {
    final buffer = StringBuffer();
    buffer.writeln(fields.join(','));
    for (final row in data) {
      buffer.writeln(fields.map((f) => '"${row[f] ?? ""}"').join(','));
    }
    return buffer.toString();
  }

  Future<void> _downloadReport(BuildContext context) async {
    final allMembers = <Map<String, dynamic>>[];
    final allLeaders = <Map<String, dynamic>>[];

    for (final entry in _RegistrationPageState.departmentMembers.entries) {
      for (final member in entry.value) {
        allMembers.add({
          'Department': entry.key,
          ...member,
        });
      }
    }

    for (final leader in _LeadershipPageState.leaders) {
      allLeaders.add(leader);
    }

    // CSV fields
    final memberFields = ['Department', 'name', 'regNo', 'phone'];
    final leaderFields = ['serial', 'name', 'regNo', 'phone', 'department', 'role'];

    // Generate CSV
    final membersCsv = _generateCsv(allMembers, memberFields);
    final leadersCsv = _generateCsv(allLeaders, leaderFields);

    // Save to files (in app's documents directory)
    final dir = await getApplicationDocumentsDirectory();
    final membersFile = File('${dir.path}/members_report.csv');
    final leadersFile = File('${dir.path}/leaders_report.csv');
    await membersFile.writeAsString(membersCsv);
    await leadersFile.writeAsString(leadersCsv);

    // Show a dialog with file paths
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reports Downloaded'),
        content: Text(
          'Members report saved at:\n${membersFile.path}\n\n'
          'Leaders report saved at:\n${leadersFile.path}\n\n'
          'You can access these files using a file manager.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.announcement),
            tooltip: 'Manage Announcements',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnnouncementAdminPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF003366),
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Color(0xFFFCB900),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download Reports'),
              onTap: () {
                Navigator.pop(context);
                _downloadReport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.announcement),
              title: const Text('Manage Announcements'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnnouncementAdminPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('View/Download PDF Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportPdfPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('App Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppDetailsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome, Admin!\n(You can add admin features here.)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

// HomeScreen for users (members) - only view announcements
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, dynamic>> departments = [
    {
      'name': 'Praise and Worship',
      'icon': Icons.music_note,
      'songs': [
        'Traditional Hymns',
        'Contemporary Worship',
        'Gospel & Black Church',
        'Charismatic/Spontaneous',
      ],
      'voices': [
        'Tenor',
        'Baritone',
        'Bass',
        'Soprano',
        'Mezzo-Soprano',
        'Alto',
      ]
    },
    {'name': 'Ushering', 'icon': Icons.people},
    {'name': 'Welfare', 'icon': Icons.favorite},
    {'name': 'Media', 'icon': Icons.camera_alt},
    {
      'name': 'Mission',
      'icon': Icons.flag,
      'subgroups': ['Evangelism', 'Outreach', 'Visitation'],
    },
    {
      'name': 'Discipleship',
      'icon': Icons.school,
      'classFellowships': ['First Year', 'Second Year', 'Third Year', 'Fourth Year'],
    },
    {
      'name': 'Bible Study',
      'icon': Icons.menu_book,
      'bibleStudyPages': [
        'Library',
        'CBR Classes',
        'Best P Class (Third Year)',
        'Best P Class (Fourth Year)',
      ]
    },
    {
      'name': 'Instrumentalist',
      'icon': Icons.piano,
      'instruments': [
        'Bass Guitar',
        'Acoustic Guitar',
        'Electric Guitar (Lead/Solo)',
        'Piano/Keys',
        'Drums',
      ]
    },
  ];

  static const List<String> leadershipRoles = [
    'Coordinator',
    'Vice Chair Person',
    'Prayer Director',
    'Mission',
    'Secretary',
    'Treasurer',
    'Organizing Secretary',
  ];

  // Helper to generate CSV from a list of maps

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kibabii University Christian Union'),
        actions: [
          IconButton(
            icon: const Icon(Icons.announcement),
            tooltip: 'View Announcements',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnnouncementViewPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF003366),
              ),
              child: Text(
                'Departments',
                style: TextStyle(
                  color: Color(0xFFFCB900),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            for (final dept in departments)
              ListTile(
                leading: Icon(dept['icon'] as IconData, color: Color(0xFFFCB900)),
                title: Text(
                  dept['name'],
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Praise and Worship special page
                  if (dept['name'] == 'Praise and Worship') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PraiseAndWorshipPage(
                          songs: dept['songs'] as List<String>,
                          voices: dept['voices'] as List<String>,
                        ),
                      ),
                    );
                  }
                  // Mission subgroups
                  else if (dept['name'] == 'Mission') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MissionSubGroupsPage(
                          subgroups: dept['subgroups'] as List<String>,
                        ),
                      ),
                    );
                  }
                  // Discipleship class fellowships
                  else if (dept['name'] == 'Discipleship') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClassFellowshipPage(
                          classFellowships: dept['classFellowships'] as List<String>,
                        ),
                      ),
                    );
                  }
                  // Bible Study special pages
                  else if (dept['name'] == 'Bible Study') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BibleStudyPages(
                          pages: dept['bibleStudyPages'] as List<String>,
                        ),
                      ),
                    );
                  }
                  // Instrumentalist registration page
                  else if (dept['name'] == 'Instrumentalist') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => InstrumentalistRegistrationPage(
                          instruments: dept['instruments'] as List<String>,
                        ),
                      ),
                    );
                  }
                  // Other departments
                  else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RegistrationPage(department: dept['name']),
                      ),
                    );
                  }
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Color(0xFFFCB900)),
              title: const Text(
                'Leadership Registration',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LeadershipPage(
                      departments: departments.map((d) => d['name'] as String).toList(),
                      roles: HomeScreen.leadershipRoles,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Welcome to KIBUCU',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Kibabii University Christian Union',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF003366),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Stand up for Jesus',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF003366),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Praise and Worship Registration Page
class PraiseAndWorshipPage extends StatefulWidget {
  final List<String> songs;
  final List<String> voices;
  const PraiseAndWorshipPage({super.key, required this.songs, required this.voices});

  @override
  State<PraiseAndWorshipPage> createState() => _PraiseAndWorshipPageState();
}

class _PraiseAndWorshipPageState extends State<PraiseAndWorshipPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController(); // Add this line
  String? _selectedVoice;
  List<String> _selectedSongs = [];

  static final List<Map<String, dynamic>> registeredMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Praise & Worship Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regNoController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  prefixIcon: Icon(Icons.confirmation_number),
                  hintText: 'e.g. bit/0013/24',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter registration number';
                  }
                  final regExp = RegExp(r'^[a-zA-Z]{3}/\d{4}/\d{2}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Format must be like bit/0013/24';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedVoice,
                decoration: const InputDecoration(
                  labelText: 'Select Voice',
                  prefixIcon: Icon(Icons.record_voice_over),
                ),
                items: widget.voices
                    .map((voice) => DropdownMenuItem(
                          value: voice,
                          child: Text(voice),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVoice = value;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select a voice' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Songs (choose as many as you can sing):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...widget.songs.map((song) => CheckboxListTile(
                    title: Text(song),
                    value: _selectedSongs.contains(song),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedSongs.add(song);
                        } else {
                          _selectedSongs.remove(song);
                        }
                      });
                    },
                  )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedSongs.isNotEmpty) {
                    setState(() {
                      registeredMembers.add({
                        'name': _nameController.text,
                        'regNo': _regNoController.text,
                        'voice': _selectedVoice!,
                        'songs': List<String>.from(_selectedSongs),
                      });
                      _nameController.clear();
                      _regNoController.clear();
                      _selectedVoice = null;
                      _selectedSongs = [];
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration successful!')),
                    );
                  } else if (_selectedSongs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select at least one song')),
                    );
                  }
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Registered Members:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...registeredMembers.map((member) => ListTile(
                    title: Text(member['name'] ?? ''),
                    subtitle: Text(
                        'Reg: ${member['regNo']}, Voice: ${member['voice']}\nSongs: ${(member['songs'] as List<String>).join(", ")}'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// Mission SubGroups Page
class MissionSubGroupsPage extends StatelessWidget {
  final List<String> subgroups;
  const MissionSubGroupsPage({super.key, required this.subgroups});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mission Sub Groups')),
      body: ListView.builder(
        itemCount: subgroups.length,
        itemBuilder: (context, index) {
          final subgroup = subgroups[index];
          return ListTile(
            leading: const Icon(Icons.group, color: Color(0xFFFCB900)),
            title: Text(subgroup),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RegistrationPage(department: subgroup),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Discipleship Class Fellowship Page
class ClassFellowshipPage extends StatelessWidget {
  final List<String> classFellowships;
  const ClassFellowshipPage({super.key, required this.classFellowships});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Fellowship')),
      body: ListView.builder(
        itemCount: classFellowships.length,
        itemBuilder: (context, index) {
          final className = classFellowships[index];
          return ListTile(
            leading: const Icon(Icons.class_, color: Color(0xFFFCB900)),
            title: Text(className),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RegistrationPage(department: className),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Bible Study Special Pages
class BibleStudyPages extends StatelessWidget {
  final List<String> pages;
  const BibleStudyPages({super.key, required this.pages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Study')),
      body: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          return ListTile(
            leading: const Icon(Icons.menu_book, color: Color(0xFFFCB900)),
            title: Text(page),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RegistrationPage(department: page),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  final String department;
  const RegistrationPage({super.key, required this.department});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _phoneController = TextEditingController();

  static final Map<String, List<Map<String, String>>> departmentMembers = {};

  @override
  Widget build(BuildContext context) {
    final members = departmentMembers[widget.department] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.department} Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regNoController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  prefixIcon: Icon(Icons.confirmation_number),
                  hintText: 'e.g. bit/0013/24',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter registration number';
                  }
                  final regExp = RegExp(r'^[a-zA-Z]{3}/\d{4}/\d{2}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Format must be like bit/0013/24';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'e.g. 0712345678',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter phone number';
                  }
                  final regExp = RegExp(r'^\d{10}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Phone number must be exactly 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      departmentMembers.putIfAbsent(widget.department, () => []);
                      departmentMembers[widget.department]!.add({
                        'name': _nameController.text,
                        'regNo': _regNoController.text,
                        'phone': _phoneController.text,
                      });
                      _nameController.clear();
                      _regNoController.clear();
                      _phoneController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Member registered!')),
                    );
                  }
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 24),
              Text(
                'Registered Members (${members.length}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...members.map((m) => ListTile(
                    title: Text(m['name'] ?? ''),
                    subtitle: Text(
                        'Reg: ${m['regNo']}, Phone: ${m['phone']}'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// Leadership Registration Page
class LeadershipPage extends StatefulWidget {
  final List<String> departments;
  final List<String> roles;
  const LeadershipPage({super.key, required this.departments, required this.roles});

  @override
  State<LeadershipPage> createState() => _LeadershipPageState();
}

class _LeadershipPageState extends State<LeadershipPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _serialController = TextEditingController(text: '123'); // Default serial number

  String? _selectedDepartment;
  String? _selectedRole;

  static final List<Map<String, String>> leaders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leadership Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _serialController,
                decoration: const InputDecoration(
                  labelText: 'Serial Number (Leaders Only)',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter serial number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regNoController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  prefixIcon: Icon(Icons.confirmation_number),
                  hintText: 'e.g. bit/0013/24',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter registration number';
                  }
                  final regExp = RegExp(r'^[a-zA-Z]{3}/\d{4}/\d{2}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Format must be like bit/0013/24';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'e.g. 0712345678',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter phone number';
                  }
                  final regExp = RegExp(r'^\d{10}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Phone number must be exactly 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.apartment),
                ),
                items: widget.departments
                    .map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select a department' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge),
                ),
                items: widget.roles
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select a role' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      leaders.add({
                        'serial': _serialController.text,
                        'name': _nameController.text,
                        'regNo': _regNoController.text,
                        'phone': _phoneController.text,
                        'department': _selectedDepartment!,
                        'role': _selectedRole!,
                      });
                      _serialController.text = '123';
                      _nameController.clear();
                      _regNoController.clear();
                      _phoneController.clear();
                      _selectedDepartment = null;
                      _selectedRole = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Leader registered!')),
                    );
                  }
                },
                child: const Text('Register Leader'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Registered Leaders:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...leaders.map((l) => ListTile(
                    title: Text('${l['name']} (${l['role']})'),
                    subtitle: Text(
                        'Dept: ${l['department']}, Reg: ${l['regNo']}, Phone: ${l['phone']}'),
                    // Serial number is not shown here, only leaders know it
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// Instrumentalist Registration Page
class InstrumentalistRegistrationPage extends StatefulWidget {
  final List<String> instruments;
  const InstrumentalistRegistrationPage({super.key, required this.instruments});

  @override
  State<InstrumentalistRegistrationPage> createState() => _InstrumentalistRegistrationPageState();
}

class _InstrumentalistRegistrationPageState extends State<InstrumentalistRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _phoneController = TextEditingController();
  List<String> _selectedInstruments = [];

  static final List<Map<String, dynamic>> registeredInstrumentalists = [];

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instrumentalist Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regNoController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  prefixIcon: Icon(Icons.confirmation_number),
                  hintText: 'e.g. bit/0013/24',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter registration number';
                  }
                  final regExp = RegExp(r'^[a-zA-Z]{3}/\d{4}/\d{2}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Format must be like bit/0013/24';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'e.g. 0712345678',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter phone number';
                  }
                  final regExp = RegExp(r'^\d{10}$');
                  if (!regExp.hasMatch(value)) {
                    return 'Phone number must be exactly 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Instruments You Play:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...widget.instruments.map((instrument) => CheckboxListTile(
                    title: Text(instrument),
                    value: _selectedInstruments.contains(instrument),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedInstruments.add(instrument);
                        } else {
                          _selectedInstruments.remove(instrument);
                        }
                      });
                    },
                  )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedInstruments.isNotEmpty) {
                    setState(() {
                      registeredInstrumentalists.add({
                        'name': _nameController.text,
                        'regNo': _regNoController.text,
                        'phone': _phoneController.text,
                        'instruments': List<String>.from(_selectedInstruments),
                      });
                      _nameController.clear();
                      _regNoController.clear();
                      _phoneController.clear();
                      _selectedInstruments = [];
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration successful!')),
                    );
                  } else if (_selectedInstruments.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select at least one instrument')),
                    );
                  }
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Registered Instrumentalists:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...registeredInstrumentalists.map((member) => ListTile(
                    title: Text(member['name'] ?? ''),
                    subtitle: Text(
                        'Reg: ${member['regNo']}, Phone: ${member['phone']}\nInstruments: ${(member['instruments'] as List<String>).join(", ")}'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// Check for empty department maps (for debugging)
void checkForEmptyDepartments() {
  for (final dept in HomeScreen.departments) {
    if (dept.isEmpty) {
      print('Found empty department map!');
    }
  }
}

class AnnouncementViewPage extends StatelessWidget {
  const AnnouncementViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: const Center(child: Text('Announcements will appear here.')),
    );
  }
}

class ReportPdfPage extends StatelessWidget {
  const ReportPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Report')),
      body: const Center(child: Text('PDF report will appear here.')),
    );
  }
}

class AnnouncementAdminPage extends StatelessWidget {
  const AnnouncementAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Announcements')),
      body: const Center(child: Text('Admin announcement management here.')),
    );
  }
}

class AppDetailsPage extends StatelessWidget {
  const AppDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Details')),
      body: const Center(
        child: Text(
          'Kibabii University Christian Union App\nVersion 1.0.0\nDeveloped by Hilary Mureri',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AnnouncementForm extends StatefulWidget {
  const AnnouncementForm({super.key});

  @override
  State<AnnouncementForm> createState() => _AnnouncementFormState();
}

class _AnnouncementFormState extends State<AnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get the current user's ID
        final userId = FirebaseAuth.instance.currentUser!.uid;

        // Add announcement to Firestore
        await FirebaseFirestore.instance.collection('announcements').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted!')),
        );

        // Clear the form
        _titleController.clear();
        _descriptionController.clear();
      } on FirebaseAuthException catch (e) {
        setState(() => _error = e.message ?? 'Failed to post announcement');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Announcement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Post Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
