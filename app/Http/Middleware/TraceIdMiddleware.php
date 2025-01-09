<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class TraceIdMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        // 从请求头获取 X-Amzn-Trace-Id
        $traceId = $request->header('X-Amzn-Trace-Id', 'N/A');
        
        // 记录到上下文，方便后续使用
        Log::withContext(['aws_trace_id' => $traceId]);
        
        // 添加到响应头，方便调试
        $response = $next($request);
        $response->headers->set('X-Amzn-Trace-Id', $traceId);
        
        // 记录访问日志
        Log::info('Request processed', [
            'path' => $request->path(),
            'method' => $request->method(),
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'trace_id' => $traceId,
            'timestamp' => now()->toIso8601String()
        ]);
        
        return $response;
    }
} 