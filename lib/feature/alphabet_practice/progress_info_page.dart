import 'package:flutter/material.dart';

class ProgressInfoPage extends StatelessWidget {
  const ProgressInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Understanding Your Progress'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Progress Dashboard Guide',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The dashboard mirrors the same stats powering Alphabet Practice, so every metric here is calculated from your saved drill attempts. Use this guide to see how each number is derived and how to act on it.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Overall Progress Section
            _buildSection(
              context,
              icon: Icons.trending_up,
              iconColor: theme.colorScheme.primary,
              title: 'Overall Progress',
              description:
                  'Displays what portion of the alphabet currently meets the mastery rule used everywhere else in Alphabet Practice.',
              details: [
                'Calculated as mastered characters ÷ total tracked characters.',
                'A character only counts as mastered after at least 10 attempts with accuracy ≥ 85%.',
                'Refreshes immediately after each drill so the percentage matches achievements and analytics.',
              ],
              theme: theme,
            ),

            const SizedBox(height: 16),

            // Character Classes Section
            _buildSection(
              context,
              icon: Icons.category,
              iconColor: Colors.purple,
              title: 'Character Classes',
              description:
                  'Progress follows the same three CharacterClass buckets you see throughout the app:',
              details: [
                'Consonants: Includes both high and low tone consonants used in reading drills.',
                'Vowels: Covers standalone vowels plus combination markers—even split-position vowels stay in this bucket.',
                'Special Characters: Tone marks and functional glyphs that modify pronunciation.',
                'Displayed in the recommended learning order (consonants → vowels → special).',
              ],
              theme: theme,
            ),

            const SizedBox(height: 16),

            // Progress Bars Section
            _buildSection(
              context,
              icon: Icons.linear_scale,
              iconColor: Colors.orange,
              title: 'Progress Bars',
              description:
                  'Each class bar reflects its own mastery percentage:',
              details: [
                'Color-coded per class (primary for consonants, secondary for vowels, amber/error for special characters).',
                'Percentage label shows mastered ÷ total characters inside that class.',
                'Bars animate when mastery data changes so you instantly notice gains.',
              ],
              theme: theme,
            ),

            const SizedBox(height: 16),

            // Statistics Section
            _buildSection(
              context,
              icon: Icons.analytics,
              iconColor: Colors.blue,
              title: 'Key Statistics',
              description:
                  'These cards pull directly from your lifetime mastery stats:',
              details: [
                'Characters Mastered: Count of characters with ≥ 85% accuracy and 10+ attempts (shown as mastered/total).',
                'Overall Accuracy: Lifetime correct ÷ total attempts, so frequently practiced characters influence it more.',
                'Practice Attempts: Total drill attempts recorded; session history lives in Analytics → History.',
              ],
              theme: theme,
            ),

            const SizedBox(height: 24),

            // How to Improve Section
            Card(
              color: theme.colorScheme.primaryContainer.withAlpha(77),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tips to Improve',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTip(
                      context,
                      '1. Practice Regularly',
                      'Daily practice builds muscle memory and improves retention.',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      context,
                      '2. Start with Introduction',
                      'Use the "Learn" button to familiarize yourself with characters before practicing.',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      context,
                      '3. Focus on Weak Areas',
                      'Open Analytics → Characters to sort by lowest accuracy and target those first.',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      context,
                      '4. Use Spaced Repetition',
                      'The Practice button always pulls characters that fall below 85% or haven\'t been reviewed lately.',
                      theme,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Mastery Levels Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mastery Levels',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMasteryLevel(
                      context,
                      'Not Started',
                      'Tracked but no practice attempts recorded yet',
                      Colors.grey,
                      '0%',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildMasteryLevel(
                      context,
                      'Learning',
                      'Has attempts logged but accuracy is under 85% or fewer than 10 attempts',
                      Colors.orange,
                      '< 85% or < 10 tries',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildMasteryLevel(
                      context,
                      'Mastered',
                      'Achieved ≥ 85% accuracy with at least 10 attempts',
                      Colors.green,
                      '≥ 85% & 10+',
                      theme,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Call to Action
            Card(
              color: theme.colorScheme.secondaryContainer.withAlpha(77),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 40,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready to Practice?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pick a class, tap Learn for guided introductions, or Practice for spaced repetition drills.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> details,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          detail,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(
    BuildContext context,
    String title,
    String description,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMasteryLevel(
    BuildContext context,
    String level,
    String description,
    Color color,
    String accuracy,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                level,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            accuracy,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
