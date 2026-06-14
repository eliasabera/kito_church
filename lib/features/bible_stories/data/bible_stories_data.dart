import 'package:kitoapp/features/bible_stories/models/bible_story.dart';

class BibleStoriesData {
  BibleStoriesData._();

  static const initialStories = [
    BibleStory(
      id: 'david_goliath',
      title: 'David & Goliath',
      summary:
          'A young shepherd trusted God and defeated a giant with courage and faith.',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=900&q=80',
    ),
    BibleStory(
      id: 'moses_red_sea',
      title: 'Moses & the Red Sea',
      summary:
          'God opened the sea for His people, showing that He always makes a way.',
      imageUrl:
          'https://images.unsplash.com/photo-1519682337058-a94d51933777?w=900&q=80',
    ),
    BibleStory(
      id: 'jonah',
      title: 'Jonah',
      summary:
          'Running from God\'s call taught Jonah that obedience brings mercy and purpose.',
      imageUrl:
          'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=80',
    ),
    BibleStory(
      id: 'daniel',
      title: 'Daniel in the Lion\'s Den',
      summary:
          'Daniel prayed faithfully and God protected him — stand firm in your beliefs.',
      imageUrl:
          'https://images.unsplash.com/photo-1518546305927-5a555bb7020d?w=900&q=80',
    ),
    BibleStory(
      id: 'good_samaritan',
      title: 'The Good Samaritan',
      summary:
          'True faith shows love in action — help others even when it costs you.',
      imageUrl:
          'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=900&q=80',
    ),
    BibleStory(
      id: 'jesus_calms_storm',
      title: 'Jesus Calms the Storm',
      summary:
          'When life feels overwhelming, Jesus brings peace to those who trust Him.',
      imageUrl:
          'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=900&q=80',
    ),
  ];
}
