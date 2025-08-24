import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/jwt_service.dart';
import '../services/secure_storage_service.dart';
import '../models/jwt_token.dart';

class JwtInfoWidget extends StatefulWidget {
  final bool showDetails;

  const JwtInfoWidget({Key? key, this.showDetails = false}) : super(key: key);

  @override
  State<JwtInfoWidget> createState() => _JwtInfoWidgetState();
}

class _JwtInfoWidgetState extends State<JwtInfoWidget> {
  JwtToken? _jwtToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJwtInfo();
  }

  Future<void> _loadJwtInfo() async {
    setState(() => _isLoading = true);

    try {
      final secureStorage = SecureStorageService(FlutterSecureStorage());
      final token = await secureStorage.getAuthToken();

      if (token != null) {
        final jwtService = JwtService();
        final jwtToken = jwtService.decodeToken(token);
        setState(() => _jwtToken = jwtToken);
      }
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_jwtToken == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No JWT token available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'JWT Token Info',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadJwtInfo,
                  tooltip: 'Refresh JWT info',
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('User ID', _jwtToken!.sub),
            _buildInfoRow('Email', _jwtToken!.email),
            _buildInfoRow('Role', _jwtToken!.appMetadata.role),
            _buildInfoRow('Tenant ID', _jwtToken!.userMetadata.tenantId),
            _buildInfoRow('Session ID', _jwtToken!.sessionId),
            _buildInfoRow('Expires', _formatDate(_jwtToken!.expirationDate)),
            _buildInfoRow('Issued', _formatDate(_jwtToken!.issuedAtDate)),

            if (widget.showDetails) ...[
              const SizedBox(height: 16),
              const Text(
                'User Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Name',
                '${_jwtToken!.userMetadata.firstName} ${_jwtToken!.userMetadata.lastName}',
              ),
              _buildInfoRow(
                'Company',
                _jwtToken!.userMetadata.metadata.company,
              ),
              _buildInfoRow(
                'Department',
                _jwtToken!.userMetadata.metadata.department,
              ),
              _buildInfoRow(
                'Location',
                _jwtToken!.userMetadata.metadata.location,
              ),
              _buildInfoRow(
                'Position',
                _jwtToken!.userMetadata.metadata.position,
              ),
              _buildInfoRow('Phone', _jwtToken!.phone),
              _buildInfoRow(
                'Email Verified',
                _jwtToken!.userMetadata.emailVerified.toString(),
              ),

              const SizedBox(height: 16),
              const Text(
                'API Credentials',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'API Key',
                _jwtToken!.userMetadata.apiKey,
                isSensitive: true,
              ),
              _buildInfoRow(
                'API Secret',
                _jwtToken!.userMetadata.apiSecret,
                isSensitive: true,
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _jwtToken!.isExpired ? Icons.warning : Icons.check_circle,
                  color: _jwtToken!.isExpired ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  _jwtToken!.isExpired ? 'Token Expired' : 'Token Valid',
                  style: TextStyle(
                    color: _jwtToken!.isExpired ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _jwtToken!.appMetadata.role == 'TENANT_ADMIN'
                      ? Icons.business
                      : Icons.admin_panel_settings,
                  color: _jwtToken!.appMetadata.role == 'TENANT_ADMIN'
                      ? Colors.blue
                      : Colors.purple,
                ),
                const SizedBox(width: 8),
                Text(
                  'Role: ${_jwtToken!.appMetadata.role}',
                  style: TextStyle(
                    color: _jwtToken!.appMetadata.role == 'TENANT_ADMIN'
                        ? Colors.blue
                        : Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (_jwtToken!.appMetadata.role == 'TENANT_ADMIN') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _jwtToken!.userMetadata.apiKey.isNotEmpty
                        ? Icons.api
                        : Icons.api_outlined,
                    color: _jwtToken!.userMetadata.apiKey.isNotEmpty
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _jwtToken!.userMetadata.apiKey.isNotEmpty
                        ? 'API Access: Enabled'
                        : 'API Access: Disabled',
                    style: TextStyle(
                      color: _jwtToken!.userMetadata.apiKey.isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ] else if (_jwtToken!.appMetadata.role == 'EASYBILL_ADMIN') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Web-Only Access',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EASYBILL_ADMIN users must use the web version for full functionality.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _jwtToken!.appMetadata.providers.contains('phone')
                      ? Icons.phone
                      : Icons.phone_disabled,
                  color: _jwtToken!.appMetadata.providers.contains('phone')
                      ? Colors.green
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Phone Verification: ${_jwtToken!.appMetadata.providers.contains('phone') ? 'Enabled' : 'Disabled'}',
                  style: TextStyle(
                    color: _jwtToken!.appMetadata.providers.contains('phone')
                        ? Colors.green
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isSensitive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              isSensitive && value.isNotEmpty ? '••••••••' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : null,
                fontFamily: isSensitive ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
