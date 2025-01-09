<?php

namespace App\Logging;

use Monolog\Formatter\JsonFormatter;
use Monolog\LogRecord;

class CustomizeFormatter extends JsonFormatter
{
    public function format(array|LogRecord $record): string
    {
        if (is_array($record)) {
            $record['datetime'] = $record['datetime']->format('Y-m-d H:i:s');
            $record['extra']['trace_id'] = $record['context']['aws_trace_id'] ?? 'N/A';
        } else {
            $record->datetime = $record->datetime->format('Y-m-d H:i:s');
            $record->extra['trace_id'] = $record->context['aws_trace_id'] ?? 'N/A';
        }

        return parent::format($record) . "\n";
    }
} 