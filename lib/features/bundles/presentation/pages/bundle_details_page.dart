import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/bundles_bloc.dart';
import '../bloc/bundles_event.dart';
import '../bloc/bundles_state.dart';
import '../widgets/bundle_details_widget.dart';
import '../widgets/bundles_loading_widget.dart';
import '../widgets/bundles_error_widget.dart';

class BundleDetailsPage extends StatelessWidget {
  final String bundleId;

  const BundleDetailsPage({super.key, required this.bundleId});

  @override
  Widget build(BuildContext context) {
    // Try to get the existing BLoC from context, if not available create a new one
    try {
      final existingBloc = context.read<BundlesBloc>();
      return BlocProvider.value(
        value: existingBloc,
        child: BundleDetailsView(bundleId: bundleId),
      );
    } catch (e) {
      // If no BLoC is available in context, create a new one
      return BlocProvider(
        create: (context) => getIt<BundlesBloc>(),
        child: BundleDetailsView(bundleId: bundleId),
      );
    }
  }
}

class BundleDetailsView extends StatefulWidget {
  final String bundleId;

  const BundleDetailsView({super.key, required this.bundleId});

  @override
  State<BundleDetailsView> createState() => _BundleDetailsViewState();
}

class _BundleDetailsViewState extends State<BundleDetailsView> {
  @override
  void initState() {
    super.initState();
    // Load bundle details after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BundlesBloc>().add(GetBundleById(widget.bundleId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bundle Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BundlesBloc>().add(GetBundleById(widget.bundleId));
            },
          ),
        ],
      ),
      body: BlocBuilder<BundlesBloc, BundlesState>(
        builder: (context, state) {
          if (state is SingleBundleLoading) {
            return const BundlesLoadingWidget();
          } else if (state is SingleBundleError) {
            return BundlesErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<BundlesBloc>().add(GetBundleById(widget.bundleId));
              },
            );
          } else if (state is SingleBundleLoaded) {
            return BundleDetailsWidget(bundle: state.bundle);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
