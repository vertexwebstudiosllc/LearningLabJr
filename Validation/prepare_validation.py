"""Create a disposable Xcode test project; never changes the user's project settings."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
work = Path('/private/tmp/LearningLabJr-validation')
project = work / 'LearningLabJr.xcodeproj'
project.mkdir(parents=True, exist_ok=True)
text = (root.parent / 'LearningLabJr.xcodeproj/project.pbxproj').read_text()
text = text.replace('path = LearningLabJr;', f'path = "{root}";')
for folder, fixture in [('LearningLabJrTests', 'CurriculumTests.swift.txt'),
                        ('LearningLabJrUITests', 'ActivitySmokeTests.swift.txt')]:
    destination = work / folder
    destination.mkdir(exist_ok=True)
    (destination / fixture.removesuffix('.txt')).write_text((root / 'Validation' / fixture).read_text())
    text = text.replace(f'path = {folder};', f'path = "{destination}";')
(project / 'project.pbxproj').write_text(text)

categories = []
for title, folder, filename in [
    ('ABCs & Phonics', 'ABCsAndPhonics', 'ABCsAndPhonicsMenu.swift'),
    ('Shapes & Colors', 'ShapesAndColors', 'ShapesAndColorsMenu.swift'),
    ('123s & Counting', '123AndCounting', 'CountingMenu.swift'),
    ('Nature Explorers', 'NatureExplorers', 'NatureExplorersMenu.swift'),
    ('Story Time', 'StoryTime', 'StoryTimeMenu.swift'),
    ('Big Feelings', 'BigFeelings', 'BigFeelingsMenu.swift'),
]:
    source = (root / folder / filename).read_text()
    names = re.findall(r'\.init\(id: "[^\"]+", title: "([^\"]+)"', source)
    if not names:
        names = re.findall(r'details = \("([^\"]+)"', source)
    assert len(names) == 12, (title, len(names))
    assert len(set(names)) == 12
    categories.append({'title': title, 'games': names})
(work / 'LearningLabJrUITests' / 'ActivityInventory.json').write_text(json.dumps(categories))
(work / 'LearningLabJrUITests' / 'LearningLabJr.storekit').write_text((root / 'LearningLabJr.storekit').read_text())
print(project)
