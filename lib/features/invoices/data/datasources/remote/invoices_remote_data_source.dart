import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/invoice_model.dart';
import '../../models/invoice_audit_log_model.dart';
import '../../models/adjust_invoice_item_request_model.dart';
import '../../models/adjust_invoice_item_response_model.dart';

abstract class InvoicesRemoteDataSource {
  Future<List<InvoiceModel>> getInvoices();
  Future<InvoiceModel> getInvoiceById(String invoiceId);
  Future<List<InvoiceModel>> getInvoicesByAccountId(String accountId);
  Future<List<InvoiceAuditLogModel>> getInvoiceAuditLogsWithHistory(
    String invoiceId,
  );
  Future<AdjustInvoiceItemResponseModel> adjustInvoiceItem(
    String invoiceId,
    AdjustInvoiceItemRequestModel request,
  );
}

@LazySingleton(as: InvoicesRemoteDataSource)
class InvoicesRemoteDataSourceImpl implements InvoicesRemoteDataSource {
  final DioClient _dioClient;

  InvoicesRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<InvoiceModel>> getInvoices() async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.invoices,
        queryParameters: {'audit': 'MINIMAL'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> invoicesJson = data['data'];
          return invoicesJson
              .map(
                (json) => InvoiceModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            'Failed to fetch invoices: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch invoices: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<InvoiceModel> getInvoiceById(String invoiceId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.getInvoiceById(invoiceId),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return InvoiceModel.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw Exception(
            'Failed to fetch invoice: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to fetch invoice: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<InvoiceModel>> getInvoicesByAccountId(String accountId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.getAccountInvoices(accountId),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> invoicesJson = data['data'];
          return invoicesJson
              .map(
                (json) => InvoiceModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            'Failed to fetch invoices by account: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch invoices by account: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<InvoiceAuditLogModel>> getInvoiceAuditLogsWithHistory(
    String invoiceId,
  ) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.getInvoiceAuditLogsWithHistory(invoiceId),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> auditLogsJson = data['data'];
          return auditLogsJson
              .map(
                (json) =>
                    InvoiceAuditLogModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            'Failed to fetch invoice audit logs: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch invoice audit logs: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<AdjustInvoiceItemResponseModel> adjustInvoiceItem(
    String invoiceId,
    AdjustInvoiceItemRequestModel request,
  ) async {
    try {
      final response = await _dioClient.dio.put(
        ApiEndpoints.adjustInvoiceItem(invoiceId),
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AdjustInvoiceItemResponseModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to adjust invoice item: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        // Try to parse error response
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          return AdjustInvoiceItemResponseModel.fromJson(errorData);
        } catch (_) {
          throw Exception('Network error: ${e.message}');
        }
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
