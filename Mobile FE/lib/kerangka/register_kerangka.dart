import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RegistrasiKerangka {
  // 1. Label Teks Kecil Abu-abu
  static Widget sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 0.5,
      ),
    );
  }

  // 2. Kerangka Judul Event
  static Widget eventTitle(String title, String category, String orgType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel("EVENT TITLE"),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionLabel("CATEGORY"),
                const SizedBox(height: 8),
                _buildBadge(
                  category,
                  AppTheme.badgeGreenBg,
                  AppTheme.badgeGreenText,
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionLabel("ORG. TYPE"),
                const SizedBox(height: 8),
                _buildBadge(
                  orgType,
                  AppTheme.badgeRedBg,
                  AppTheme.badgeRedText,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // 3. Kerangka Organizer
  static Widget organizerBox(String name, String role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel("ORGANIZER DETAILS"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.badgeRedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: AppTheme.badgeRedText),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Kerangka Jadwal (Schedule)
  static Widget scheduleBox(
    String startDate,
    String startTime,
    String endDate,
    String endTime,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel("EVENT SCHEDULE"),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTimeBox("STARTS", startDate, startTime)),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeBox("ENDS", endDate, endTime)),
          ],
        ),
      ],
    );
  }

  // 5. Kerangka Info Row (Lokasi, Link, CP)
  static Widget infoRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.badgeRedText, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionLabel(label),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: isLink ? Colors.blue : AppTheme.darkBlue,
                  decoration: isLink
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Internal untuk file ini saja ---
  static Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  static Widget _buildTimeBox(String label, String date, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.badgeRedText,
            ),
          ),
        ],
      ),
    );
  }
}
