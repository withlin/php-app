<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laravel Environment Demo</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
    <div class="min-h-screen flex items-center justify-center">
        <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8 m-4">
            <div class="text-center">
                <h1 class="text-4xl font-bold text-gray-900 mb-4">环境变量展示</h1>
                <div class="mb-8">
                    <div class="text-sm font-medium text-gray-500 mb-2">当前环境变量值</div>
                    <div class="text-2xl font-bold text-indigo-600">{{ $envValue }}</div>
                </div>
                <div class="border-t border-gray-200 pt-4">
                    <div class="text-sm font-medium text-gray-500 mb-2">Amazon Trace ID</div>
                    <div class="text-md font-mono bg-gray-50 p-2 rounded">
                        {{ $traceId ?? '未提供' }}
                    </div>
                </div>
                <div class="mt-8 text-sm text-gray-500">
                    访问时间: {{ now()->format('Y-m-d H:i:s') }}
                </div>
            </div>
        </div>
    </div>
</body>
</html> 