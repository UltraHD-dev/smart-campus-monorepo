#!/bin/bash
echo "Проверка proto файла..."
echo "1. Содержимое:"
cat proto/simple_auth.proto
echo ""
echo "2. Проверяем директории:"
ls -la proto/
ls -la shared/internalpb/
