import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:calcular_parte/bloc/reporte_bloc.dart';
import 'package:calcular_parte/bloc/reporte_event.dart';
import 'package:calcular_parte/theme/app_colors.dart';
import 'package:calcular_parte/widgets/alert_dialog_base.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final resumenText = context.read<ReporteBloc>().getResumenText();
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Opciones'),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del resumen
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.grey500),
                        const SizedBox(width: 8),
                        Text(
                          'Información Guardada',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        resumenText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Opciones de acciones
            Text(
              'Acciones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.copy,
              title: 'Copiar Información',
              subtitle: 'Copiar todos los datos al portapapeles',
              onTap: () => _copyToClipboard(context, resumenText),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.share,
              title: 'Compartir Información',
              subtitle: 'Compartir datos por otras aplicaciones',
              onTap: () => _shareData(context, resumenText),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.delete_forever,
              title: 'Eliminar Datos',
              subtitle: 'Borrar todos los datos guardados',
              onTap: () => _showClearDataDialog(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.error : AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDestructive ? AppColors.error : AppColors.grey500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDestructive ? AppColors.error : AppColors.grey500,
        ),
        onTap: onTap,
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Información copiada al portapapeles'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareData(BuildContext context, String text) {
    SharePlus.instance.share(
      ShareParams(
        title: 'Reporte de Parte Carabineros',
        subject: 'Reporte de Parte',
        text: text,
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialogBase(
          title: 'Eliminar todos los datos',
          content: const Text(
            '¿Estás seguro de que quieres eliminar todos los datos de la aplicación? '
            'Esta acción no se puede deshacer.',
          ),
          confirmText: 'Eliminar',
          onConfirm: () {
            context.read<ReporteBloc>().add(ClearAppData());
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Cerrar la página de ajustes
          },
        );
      },
    );
  }
} 