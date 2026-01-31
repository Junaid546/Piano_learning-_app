import '../models/achievement.dart';

class AchievementsData {
  static List<Achievement> getAllAchievements() {
    return [
      // LESSONS ACHIEVEMENTS
      const Achievement(
        id: 'first_steps',
        title: 'First Steps',
        description: 'Complete your first lesson',
        iconName: 'school',
        requirement: 1,
        rarity: 'bronze',
        category: 'lessons',
      ),
      const Achievement(
        id: 'dedicated_learner',
        title: 'Dedicated Learner',
        description: 'Complete 10 lessons',
        iconName: 'menu_book',
        requirement: 10,
        rarity: 'silver',
        category: 'lessons',
      ),
      const Achievement(
        id: 'knowledge_seeker',
        title: 'Knowledge Seeker',
        description: 'Complete 25 lessons',
        iconName: 'auto_stories',
        requirement: 25,
        rarity: 'gold',
        category: 'lessons',
      ),
      const Achievement(
        id: 'master_student',
        title: 'Master Student',
        description: 'Complete all available lessons',
        iconName: 'workspace_premium',
        requirement: 50,
        rarity: 'platinum',
        category: 'lessons',
      ),

      // PRACTICE ACHIEVEMENTS
      const Achievement(
        id: 'practice_rookie',
        title: 'Practice Rookie',
        description: 'Complete 10 practice sessions',
        iconName: 'fitness_center',
        requirement: 10,
        rarity: 'bronze',
        category: 'practice',
      ),
      const Achievement(
        id: 'practice_enthusiast',
        title: 'Practice Enthusiast',
        description: 'Complete 25 practice sessions',
        iconName: 'sports_gymnastics',
        requirement: 25,
        rarity: 'silver',
        category: 'practice',
      ),
      const Achievement(
        id: 'practice_pro',
        title: 'Practice Pro',
        description: 'Complete 50 practice sessions',
        iconName: 'emoji_events',
        requirement: 50,
        rarity: 'gold',
        category: 'practice',
      ),
      const Achievement(
        id: 'practice_legend',
        title: 'Practice Legend',
        description: 'Complete 100 practice sessions',
        iconName: 'military_tech',
        requirement: 100,
        rarity: 'platinum',
        category: 'practice',
      ),

      // STREAK ACHIEVEMENTS
      const Achievement(
        id: 'getting_started',
        title: 'Getting Started',
        description: 'Practice for 2 days in a row',
        iconName: 'calendar_today',
        requirement: 2,
        rarity: 'bronze',
        category: 'streak',
      ),
      const Achievement(
        id: 'consistent',
        title: 'Consistent',
        description: 'Maintain a 3-day practice streak',
        iconName: 'event_repeat',
        requirement: 3,
        rarity: 'bronze',
        category: 'streak',
      ),
      const Achievement(
        id: 'committed',
        title: 'Committed',
        description: 'Maintain a 7-day practice streak',
        iconName: 'event_available',
        requirement: 7,
        rarity: 'silver',
        category: 'streak',
      ),
      const Achievement(
        id: 'dedicated',
        title: 'Dedicated',
        description: 'Maintain a 14-day practice streak',
        iconName: 'date_range',
        requirement: 14,
        rarity: 'gold',
        category: 'streak',
      ),
      const Achievement(
        id: 'unstoppable',
        title: 'Unstoppable',
        description: 'Maintain a 30-day practice streak',
        iconName: 'celebration',
        requirement: 30,
        rarity: 'platinum',
        category: 'streak',
      ),

      // ACCURACY ACHIEVEMENTS
      const Achievement(
        id: 'good_aim',
        title: 'Good Aim',
        description: 'Achieve 80% accuracy in a session',
        iconName: 'gps_fixed',
        requirement: 80,
        rarity: 'bronze',
        category: 'accuracy',
      ),
      const Achievement(
        id: 'sharp_shooter',
        title: 'Sharp Shooter',
        description: 'Achieve 90% accuracy in a session',
        iconName: 'my_location',
        requirement: 90,
        rarity: 'silver',
        category: 'accuracy',
      ),
      const Achievement(
        id: 'perfect_practice',
        title: 'Perfect Practice',
        description: 'Achieve 100% accuracy in a session',
        iconName: 'stars',
        requirement: 100,
        rarity: 'gold',
        category: 'accuracy',
      ),

      // NOTES ACHIEVEMENTS
      const Achievement(
        id: 'note_novice',
        title: 'Note Novice',
        description: 'Play 100 notes correctly',
        iconName: 'music_note',
        requirement: 100,
        rarity: 'bronze',
        category: 'notes',
      ),
      const Achievement(
        id: 'note_apprentice',
        title: 'Note Apprentice',
        description: 'Play 500 notes correctly',
        iconName: 'library_music',
        requirement: 500,
        rarity: 'silver',
        category: 'notes',
      ),
      const Achievement(
        id: 'note_expert',
        title: 'Note Expert',
        description: 'Play 1,000 notes correctly',
        iconName: 'queue_music',
        requirement: 1000,
        rarity: 'gold',
        category: 'notes',
      ),
      const Achievement(
        id: 'note_master',
        title: 'Note Master',
        description: 'Play 5,000 notes correctly',
        iconName: 'piano',
        requirement: 5000,
        rarity: 'platinum',
        category: 'notes',
      ),

      // TIME ACHIEVEMENTS
      const Achievement(
        id: 'time_traveler',
        title: 'Time Traveler',
        description: 'Practice for 1 hour total',
        iconName: 'access_time',
        requirement: 60,
        rarity: 'bronze',
        category: 'time',
      ),
      const Achievement(
        id: 'time_investor',
        title: 'Time Investor',
        description: 'Practice for 5 hours total',
        iconName: 'schedule',
        requirement: 300,
        rarity: 'silver',
        category: 'time',
      ),
      const Achievement(
        id: 'time_master',
        title: 'Time Master',
        description: 'Practice for 10 hours total',
        iconName: 'timer',
        requirement: 600,
        rarity: 'gold',
        category: 'time',
      ),
      const Achievement(
        id: 'time_legend',
        title: 'Time Legend',
        description: 'Practice for 25 hours total',
        iconName: 'hourglass_full',
        requirement: 1500,
        rarity: 'platinum',
        category: 'time',
      ),
    ];
  }

  static List<Achievement> getAchievementsByCategory(String category) {
    return getAllAchievements().where((a) => a.category == category).toList();
  }

  static Achievement? getAchievementById(String id) {
    try {
      return getAllAchievements().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
