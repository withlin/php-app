<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class HomeController extends Controller
{
    public function index(Request $request)
    {
        // 获取环境变量
        $envValue = env('CUSTOM_ENV_VAR', 'Default Value');
        $traceId = $request->header('X-Amzn-Trace-Id');

        // 记录访问日志
        Log::info('Page Access', [
            'path' => $request->path(),
            'method' => $request->method(),
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'x_amzn_trace_id' => $traceId,
            'timestamp' => now()->toIso8601String()
        ]);

        // 返回视图
        return view('welcome', [
            'envValue' => $envValue,
            'traceId' => $traceId
        ]);
    }
} 