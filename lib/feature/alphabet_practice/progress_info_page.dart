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
                      'Your progress dashboard tracks your learning journey through the Tai Dam alphabet. Here\'s what each metric means and how to use them effectively.',
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
                  'Shows the percentage of all characters you\'ve mastered across the entire Tai Dam alphabet.',
              details: [
                'Based on total mastered characters vs. total characters',
                'A character is "mastered" when you achieve 80%+ accuracy',
                'This gives you a quick snapshot of your overall learning',
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
                  'The Tai Dam alphabet is organized into different classes, each with its own progress indicator:',
              details: [
                'Consonants: The basic consonant sounds',
                'Vowels: Vowel markers that combine with consonants',
                'Vowel Combinations: Complex vowel patterns',
                'Special Characters: Tone marks and special symbols',
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
              description: 'Each character class shows its mastery progress:',
              details: [
                'Green bar: Your current mastery level',
                'Percentage: Shows exact completion (e.g., "6/21")',
                'Fill animation shows progress at a glance',
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
              description: 'Important numbers to track your learning:',
              details: [
                'Characters Mastered: Total characters with 80%+ accuracy',
                'Practice Sessions: Number of completed learning sessions',
                'Overall Accuracy: Your average correctness across all attempts',
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
                      'Check Analytics to see which characters need more practice.',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildTip(
                      context,
                      '4. Use Spaced Repetition',
                      'The app automatically identifies characters that need review.',
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
                      'Character not yet practiced',
                      Colors.grey,
                      '0%',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildMasteryLevel(
                      context,
                      'Learning',
                      'Practicing but not yet mastered',
                      Colors.orange,
                      '< 80%',
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildMasteryLevel(
                      context,
                      'Mastered',
                      'Consistent accuracy achieved',
                      Colors.green,
                      '≥ 80%',
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
                            'Choose a character class and start your learning journey!',
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
