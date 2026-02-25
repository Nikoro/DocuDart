import 'package:test/test.dart';
import 'package:docudart/src/models/license.dart';
import 'package:docudart/src/models/license_parser.dart';

void main() {
  group('LicenseParser', () {
    test('returns null for empty content', () {
      expect(LicenseParser.parse(''), isNull);
      expect(LicenseParser.parse('   '), isNull);
    });

    test('parses MIT license', () {
      const content = '''
MIT License

Copyright (c) 2026 Dominik Krajcer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction.
''';
      final License(:type, :year, :holder) = LicenseParser.parse(content)!;
      expect(type, equals(LicenseType.mit));
      expect(year, equals('2026'));
      expect(holder, equals('Dominik Krajcer'));
    });

    test('parses BSD 3-Clause license', () {
      const content = '''
BSD 3-Clause License

Copyright (c) 2024, John Doe
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
''';
      final License(:type, :year, :holder) = LicenseParser.parse(content)!;
      expect(type, equals(LicenseType.bsd3));
      expect(year, equals('2024'));
      expect(holder, equals('John Doe'));
    });

    test('parses BSD 2-Clause license', () {
      const content = '''
BSD 2-Clause License

Copyright (c) 2023, Jane Smith

Redistribution and use in source and binary forms, with or without
modification, are permitted.
''';
      final License(:type, :year, :holder) = LicenseParser.parse(content)!;
      expect(type, equals(LicenseType.bsd2));
      expect(year, equals('2023'));
      expect(holder, equals('Jane Smith'));
    });

    test('parses Apache 2.0 license', () {
      const content = '''
                                 Apache License
                           Version 2.0, January 2004

Copyright 2025 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
''';
      final License(:type, :year, :holder) = LicenseParser.parse(content)!;
      expect(type, equals(LicenseType.apache2));
      expect(year, equals('2025'));
      expect(holder, equals('Google LLC'));
    });

    test('parses GPL v3 license', () {
      const content = '''
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2007 Free Software Foundation, Inc.
''';
      final License(:type, :year, :holder) = LicenseParser.parse(content)!;
      expect(type, equals(LicenseType.gpl3));
      expect(year, equals('2007'));
      expect(holder, equals('Free Software Foundation, Inc'));
    });

    test('parses GPL v2 license', () {
      const content = '''
GNU GENERAL PUBLIC LICENSE
Version 2, June 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.
''';
      final license = LicenseParser.parse(content)!;
      expect(license.type, equals(LicenseType.gpl2));
    });

    test('parses ISC license', () {
      const content = '''
ISC License

Copyright (c) 2024 Alice Bob

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.
''';
      final License(:type, :year, :holder) = LicenseParser.parse(content)!;
      expect(type, equals(LicenseType.isc));
      expect(year, equals('2024'));
      expect(holder, equals('Alice Bob'));
    });

    test('parses LGPL license', () {
      const content = '''
GNU LESSER GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2007 Free Software Foundation, Inc.
''';
      final license = LicenseParser.parse(content)!;
      expect(license.type, equals(LicenseType.lgpl));
    });

    test('parses AGPL license', () {
      const content = '''
GNU AFFERO GENERAL PUBLIC LICENSE
Version 3, 19 November 2007

Copyright (C) 2007 Free Software Foundation, Inc.
''';
      final license = LicenseParser.parse(content)!;
      expect(license.type, equals(LicenseType.agpl));
    });

    test('parses MPL 2.0 license', () {
      const content = '''
Mozilla Public License Version 2.0

Copyright (c) 2024 Mozilla Foundation
''';
      final license = LicenseParser.parse(content)!;
      expect(license.type, equals(LicenseType.mpl2));
      expect(license.holder, equals('Mozilla Foundation'));
    });

    test('parses Unlicense (no copyright holder)', () {
      const content = '''
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any means.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

For more information, please refer to <https://unlicense.org>
''';
      final License(:type, :holder, :year) = LicenseParser.parse(content)!;
      expect(type, equals(LicenseType.unlicense));
      expect(holder, isNull);
      expect(year, isNull);
    });

    test('parses CC0 license', () {
      const content = '''
CC0 1.0 Universal

Statement of Purpose

The laws of most jurisdictions throughout the world automatically confer
exclusive Copyright and Related Rights upon the creator.
''';
      final license = LicenseParser.parse(content)!;
      expect(license.type, equals(LicenseType.cc0));
    });

    test('parses WTFPL license', () {
      const content = '''
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.
''';
      final license = LicenseParser.parse(content)!;
      expect(license.type, equals(LicenseType.wtfpl));
      expect(license.holder, equals('Sam Hocevar <sam@hocevar.net>'));
    });

    test('handles year ranges', () {
      const content = '''
MIT License

Copyright (c) 2020-2026 Some Developer
''';
      final License(:type, :year, :holder) = LicenseParser.parse(content)!;
      expect(type, equals(LicenseType.mit));
      expect(year, equals('2020-2026'));
      expect(holder, equals('Some Developer'));
    });

    test('handles unicode copyright symbol', () {
      const content = '''
MIT License

Copyright © 2026 Unicode Dev
''';
      final license = LicenseParser.parse(content)!;
      expect(license.year, equals('2026'));
      expect(license.holder, equals('Unicode Dev'));
    });

    test('returns unknown type for unrecognized license', () {
      const content = '''
Some Custom License

Copyright (c) 2026 Custom Author

You can do whatever you want with this.
''';
      final license = LicenseParser.parse(content)!;
      expect(license.type, equals(LicenseType.unknown));
      expect(license.holder, equals('Custom Author'));
    });

    test('returns first copyright holder when multiple present', () {
      const content = '''
MIT License

Copyright (c) 2024 First Author
Copyright (c) 2025 Second Author

Permission is hereby granted.
''';
      final license = LicenseParser.parse(content)!;
      expect(license.holder, equals('First Author'));
    });

    test('handles uppercase (C) in copyright', () {
      const content = '''
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2026 My Organization
''';
      final license = LicenseParser.parse(content)!;
      expect(license.holder, equals('My Organization'));
    });
  });
}
