import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color PRIMARY = Color(0xFF36261C);
const Color WHITE = Color(0xFFFFFFFF);

final String host = ((dotenv.env['HOST'] ?? ''))
    .replaceAll(RegExp(r"\s+"), '') // remove all whitespace
    .replaceAll(RegExp(r"/+$"), ''); // remove trailing slashes
