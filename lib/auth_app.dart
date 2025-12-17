import 'dart:convert';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'hero.dart';
import 'profile_page.dart';

enum AppPage { home, profile }

class AuthApp extends StatefulWidget {
  final Auth0? auth0;
  const AuthApp({this.auth0, final Key? key}) : super(key: key);

  @override
  State<AuthApp> createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> {
  UserProfile? _user;
  String? _accessToken;
  Map<String, dynamic>? _userInfoData;
  bool _isLoadingUserInfo = false;
  AppPage _currentPage = AppPage.home;

  late Auth0 auth0;
  late Auth0Web auth0Web;

  @override
  void initState() {
    super.initState();
    auth0 = widget.auth0 ??
        Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    auth0Web =
        Auth0Web(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);

    if (kIsWeb) {
      auth0Web.onLoad().then((final credentials) {
        setState(() {
          _user = credentials?.user;
          _accessToken = credentials?.accessToken;
          if (_user != null) {
            _currentPage = AppPage.profile;
          }
        });
        if (credentials?.accessToken != null) {
          _fetchUserInfo(credentials!.accessToken);
        }
      });
    }
  }

  Future<void> _fetchUserInfo(String accessToken) async {
    setState(() {
      _isLoadingUserInfo = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://sample-userinfo.dev.upbond.io/userinfo'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userInfoData = json.decode(response.body);
          _isLoadingUserInfo = false;
        });
      } else {
        print('Failed to fetch userinfo: ${response.statusCode}');
        setState(() {
          _isLoadingUserInfo = false;
        });
      }
    } catch (e) {
      print('Error fetching userinfo: $e');
      setState(() {
        _isLoadingUserInfo = false;
      });
    }
  }

  Future<void> login() async {
    try {
      if (kIsWeb) {
        return auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
      }

      var credentials = await auth0
          .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
          .login(
            useHTTPS: defaultTargetPlatform == TargetPlatform.android,
          );

      setState(() {
        _user = credentials.user;
        _accessToken = credentials.accessToken;
        _currentPage = AppPage.profile;
      });

      _fetchUserInfo(credentials.accessToken);
    } catch (e) {
      print(e);
    }
  }

  Future<void> register() async {
    try {
      if (kIsWeb) {
        return auth0Web.loginWithRedirect(
          redirectUrl: 'http://localhost:3000',
          parameters: {
            'prompt': 'login',
            'screen_hint': 'signup',
            'type': '2',
          },
        );
      }

      var credentials = await auth0
          .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
          .login(
            useHTTPS: defaultTargetPlatform == TargetPlatform.android,
            parameters: {
              'prompt': 'login',
              'screen_hint': 'signup',
              'type': '2',
            },
          );

      setState(() {
        _user = credentials.user;
        _accessToken = credentials.accessToken;
        _currentPage = AppPage.profile;
      });

      _fetchUserInfo(credentials.accessToken);
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    try {
      if (kIsWeb) {
        await auth0Web.logout(returnToUrl: 'http://localhost:3000');
      } else {
        await auth0
            .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
            .logout();

        setState(() {
          _user = null;
          _accessToken = null;
          _userInfoData = null;
          _currentPage = AppPage.home;
        });
      }
    } catch (e) {
      print(e);
      await auth0.credentialsManager.clearCredentials();
      setState(() {
        _user = null;
        _accessToken = null;
        _userInfoData = null;
        _currentPage = AppPage.home;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: cardColor,
          foregroundColor: textPrimary,
          elevation: 1,
        ),
      ),
      home: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Logo - always navigate to home
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentPage = AppPage.home;
                });
              },
              child: Image.network(
                upbondLogoUrl,
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.business, color: Colors.grey),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_user == null) {
      // Non-authenticated nav
      return [
        TextButton(
          onPressed: login,
          child: const Text(
            '登録',
            style: TextStyle(color: textPrimary),
          ),
        ),
        TextButton(
          onPressed: login,
          child: const Text(
            'ログイン',
            style: TextStyle(color: textPrimary),
          ),
        ),
        const SizedBox(width: 8),
      ];
    } else {
      // Authenticated nav with dropdown
      return [
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: Image.network(
                      getAvatarUrl(_user?.email),
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Colors.grey);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: textSecondary),
              ],
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'home',
              child: Row(
                children: [
                  const Icon(Icons.home_outlined, size: 20, color: textSecondary),
                  const SizedBox(width: 12),
                  const Text('ホーム'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 20, color: textSecondary),
                  const SizedBox(width: 12),
                  const Text('プロフィール'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.power_settings_new, size: 20, color: Colors.red),
                  const SizedBox(width: 12),
                  const Text('ログアウト', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'home':
                setState(() => _currentPage = AppPage.home);
                break;
              case 'profile':
                setState(() => _currentPage = AppPage.profile);
                break;
              case 'logout':
                logout();
                break;
            }
          },
        ),
      ];
    }
  }

  Widget _buildBody() {
    if (_user == null) {
      // Not logged in - show hero with login buttons
      return HeroWidget(
        onLogin: login,
        onRegister: register,
        showButtons: true,
      );
    }

    // Logged in
    switch (_currentPage) {
      case AppPage.home:
        // Home page for authenticated user - hero without buttons
        return const HeroWidget(showButtons: false);
      case AppPage.profile:
        return ProfilePage(
          user: _user,
          userInfoData: _userInfoData,
          isLoading: _isLoadingUserInfo,
        );
    }
  }
}
