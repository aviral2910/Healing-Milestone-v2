import re

with open('lib/shared/widgets/qr_share_preview.dart', 'r') as f:
    content = f.read()

content = content.replace(
    """Text(
                  'Share QR Code',
                  style: theme.textTheme.headlineLarge?.copyWith(fontSize: 22),
                ),""",
    """Text(
                  'Share QR Code',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),"""
)

content = content.replace(
    """ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareQrCode,
              icon: _isSharing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Icon(Icons.ios_share_rounded, color: theme.colorScheme.onPrimary),
              label: Text(
                _isSharing ? 'Sharing...' : 'Share Image',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
            ),""",
    """ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareQrCode,
              icon: _isSharing
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Icon(Icons.ios_share_rounded, size: 20, color: theme.colorScheme.onPrimary),
              label: Text(
                _isSharing ? 'Sharing...' : 'Share Image',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
            ),"""
)

content = content.replace(
    """Text(
                      widget.qrBottomText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),""",
    """Text(
                      widget.qrBottomText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),"""
)

with open('lib/shared/widgets/qr_share_preview.dart', 'w') as f:
    f.write(content)
