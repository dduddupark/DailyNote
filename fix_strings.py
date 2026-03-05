import codecs

def fix_file(path, is_korean):
    with codecs.open(path, 'r', 'utf-8') as f:
        content = f.read()

    if is_korean:
        replacements = {
            '"tag_exercise" = "🏋️‍♀️ 운동";': '"tag_exercise" = "🏋️‍♀️ 운동";',
            '"tag_running" = "🏃 러닝";': '"tag_running" = "🏃 러닝";',
            '"tag_reading" = "📚 독서";': '"tag_reading" = "📚 독서";',
            '"tag_study" = "📝 공부";': '"tag_study" = "📝 공부";',
            '"tag_movie" = "🎬 영화";': '"tag_movie" = "🎬 영화";',
            '"tag_meeting" = "👥 만남";': '"tag_meeting" = "👥 만남";',
            '"tag_work" = "💼 업무";': '"tag_work" = "💼 업무";',
            '"tag_dining" = "🍻 회식";': '"tag_dining" = "🍻 회식";',
            '"tag_businesstrip" = "✈️ 출장";': '"tag_businesstrip" = "✈️ 출장";',
            '"tag_travel" = "✈️ 여행";': '"tag_travel" = "✈️ 여행";',
            '"tag_cafe" = "☕️ 카페";': '"tag_cafe" = "☕️ 카페";',
            '"tag_health" = "🍎 건강";': '"tag_health" = "🍎 건강";',
            '"tag_idea" = "💡 아이디어";': '"tag_idea" = "💡 아이디어";',
            '"tag_plan" = "📅 계획";': '"tag_plan" = "📅 계획";',
            '"tag_book" = "📖 책";': '"tag_book" = "📖 책";',
            '"tag_walk" = "🌿 산책";': '"tag_walk" = "🌿 산책";'
        }
    else:
        replacements = {
            '"tag_exercise" = "🏋️‍♀️ Exercise";': '"tag_exercise" = "🏋️‍♀️ Exercise";',
            '"tag_running" = "🏃 Running";': '"tag_running" = "🏃 Running";',
            '"tag_reading" = "📚 Reading";': '"tag_reading" = "📚 Reading";',
            '"tag_study" = "📝 Study";': '"tag_study" = "📝 Study";',
            '"tag_movie" = "🎬 Movie";': '"tag_movie" = "🎬 Movie";',
            '"tag_meeting" = "👥 Meeting";': '"tag_meeting" = "👥 Meeting";',
            '"tag_work" = "💼 Work";': '"tag_work" = "💼 Work";',
            '"tag_dining" = "🍻 Dining";': '"tag_dining" = "🍻 Dining";',
            '"tag_businesstrip" = "✈️ Business Trip";': '"tag_businesstrip" = "✈️ Business Trip";',
            '"tag_travel" = "✈️ Travel";': '"tag_travel" = "✈️ Travel";',
            '"tag_cafe" = "☕️ Cafe";': '"tag_cafe" = "☕️ Cafe";',
            '"tag_health" = "🍎 Health";': '"tag_health" = "🍎 Health";',
            '"tag_idea" = "💡 Idea";': '"tag_idea" = "💡 Idea";',
            '"tag_plan" = "📅 Plan";': '"tag_plan" = "📅 Plan";',
            '"tag_book" = "📖 Book";': '"tag_book" = "📖 Book";',
            '"tag_walk" = "🌿 Walk";': '"tag_walk" = "🌿 Walk";'
        }

    idx = content.find("/* Tags */")
    if idx != -1:
        base_content = content[:idx]
        
        tags_content = "/* Tags */\n"
        for v in replacements.values():
            tags_content += v + "\n"
        
        tags_content += "\n/* Toast Messages */\n"
        if is_korean:
            tags_content += '"save_failed" = "저장에 실패했습니다.";\n'
            tags_content += '"delete_failed" = "삭제에 실패했습니다.";\n'
            tags_content += '"test_data_injected" = "테스트 데이터가 주입되었습니다.";\n'
            tags_content += '"fetch_error" = "불러오기 에러: %@";\n'
            tags_content += '"analysis_complete" = "분석 완료: %d개 업데이트 됨";\n'
            tags_content += '"delete_success" = "기록이 삭제되었습니다.";\n'
        else:
            tags_content += '"save_failed" = "Save failed.";\n'
            tags_content += '"delete_failed" = "Delete failed.";\n'
            tags_content += '"test_data_injected" = "Test data injected.";\n'
            tags_content += '"fetch_error" = "Fetch Error: %@";\n'
            tags_content += '"analysis_complete" = "Analysis Complete: %d updated";\n'
            tags_content += '"delete_success" = "Record deleted successfully.";\n'

        new_content = base_content + tags_content
        with codecs.open(path, 'w', 'utf-8') as f:
            f.write(new_content)

fix_file("/Users/suyeonpark/Develop/DailyNote/DailyNote/ko.lproj/Localizable.strings", True)
fix_file("/Users/suyeonpark/Develop/DailyNote/DailyNote/en.lproj/Localizable.strings", False)
print("done")
