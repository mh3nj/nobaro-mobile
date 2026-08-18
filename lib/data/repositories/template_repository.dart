import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/models/template.dart';
import '../../core/utils/date_utils.dart';

class TemplateRepository {
  static final List<Template> builtinTemplates = [
    Template(
      id: "builtin_daily",
      name: "Daily Check-In",
      description: "3 questions to ground you in the day",
      tags: "#daily #checkin",
    ),
    Template(
      id: "builtin_gratitude",
      name: "Gratitude Log",
      description: "Three things you are grateful for today",
      tags: "#gratitude #positivity",
    ),
    Template(
      id: "builtin_weekly",
      name: "Weekly Reflection",
      description: "Review your week — wins, struggles, lessons",
      tags: "#weekly #reflection",
    ),
    Template(
      id: "builtin_letter",
      name: "Letter to Self",
      description: "Start with 'Dear me...'",
      tags: "#letter #self",
    ),
  ];

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/templates.json');
  }

  Future<List<Template>> load() async {
    try {
      final file = await _file;
      if (!await file.exists()) return List.from(builtinTemplates);
      final content = await file.readAsString();
      final List<dynamic> json = jsonDecode(content);
      final user = json.map((e) => Template.fromJson(e)).toList();
      return [...builtinTemplates, ...user];
    } catch (e) {
      return List.from(builtinTemplates);
    }
  }

  Future<void> save(List<Template> all) async {
    final user = all.where((t) => !t.id.startsWith('builtin_')).toList();
    final file = await _file;
    await file.writeAsString(jsonEncode(user.map((t) => t.toJson()).toList()));
  }

  String expandContent(Template template) {
    final t = DateHelper.today();
    final now = DateTime.now();
    final dow = _getDayOfWeek(now.weekday);

    if (template.id == "builtin_daily") {
      return "Daily Check-In — $t ($dow)\n\n"
             "How am I feeling right now?\n\n\n"
             "What happened today that matters?\n\n\n"
             "What do I want to remember from this day?\n\n";
    }
    if (template.id == "builtin_gratitude") {
      return "Gratitude Log — $t\n\n"
             "1. I am grateful for...\n\n\n"
             "2. Something small that made me smile...\n\n\n"
             "3. A person I appreciate today...\n\n";
    }
    if (template.id == "builtin_weekly") {
      return "Weekly Reflection — Week of $t\n\n"
             "WINS this week:\n\n\n"
             "STRUGGLES this week:\n\n\n"
             "What I learned:\n\n\n"
             "What I carry into next week:\n\n";
    }
    if (template.id == "builtin_letter") {
      return "Dear me,\n\n"
             "Today is $t and I want you to know...\n\n\n"
             "What scares me right now:\n\n\n"
             "What excites me right now:\n\n\n"
             "Love,\nPast you ($t)";
    }

    String content = template.content;
    content = content.replaceAll("{DATE}", t);
    content = content.replaceAll("{DAY_OF_WEEK}", dow);
    return content;
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return "Monday";
      case 2: return "Tuesday";
      case 3: return "Wednesday";
      case 4: return "Thursday";
      case 5: return "Friday";
      case 6: return "Saturday";
      case 7: return "Sunday";
      default: return "";
    }
  }
}
