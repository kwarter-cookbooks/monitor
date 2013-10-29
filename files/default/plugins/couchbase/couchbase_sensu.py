#!/usr/bin/env python

import json
import subprocess
import sys
import time

CACHEFILE = '/var/tmp/couchbase_last_run.json'

"""Markdown
Stats are defined at https://github.com/membase/ep-engine/blob/master/docs/stats.org

* ep_commit_time_total: Cumulative milliseconds spent committing
* ep_io_num_read: Number of io read operations
* ep_io_num_write: Number of io write operations
* ep_io_read_bytes: Number of bytes read (key + values)
* ep_io_write_bytes: Number of bytes written (key + values)
* ep_item_begin_failed: Number of times a transaction failed to start due to storage errors
* ep_item_commit_failed: Number of times a transaction failed to commit due to storage errors
* ep_item_flush_failed: Number of times an item failed to flush due to storage errors
* ep_kv_size: Memory used to store item metadata, keys and values, no
    matter the vbucket's state. If an item's value is ejected, this stat will
    be decremented by the size of the item's value.
* ep_oom_errors: Number of times unrecoverable OOMs
* ep_pending_ops: Number of ops awaiting pending
* ep_queue_size: Number of items queued for storage
* ep_total_enqueued: Total number of items queued for persistence
* ep_total_persisted: Total number of items persisted
"""  # pylint: disable=W0105

ABSOLUTE_LIMITS = [
    ('ep_kv_size', 3100, 5000),
]

# Rare events that are always notable if their count increases
DELTA_LIMITS = [
    ('ep_oom_errors', 0, 0),
    ('ep_item_begin_failed', 0, 0),
    ('ep_item_commit_failed', 0, 0),
    ('ep_item_flush_failed', 0, 0),
    ('ep_oom_errors', 0, 0),
]

# Item count delta per second
RATE_LIMITS = [
    ('ep_io_read_bytes', 100*1024*1024, 200*1024*1024),
    ('ep_io_write_bytes', 50*1024*1024, 100*1024*1024),
    ('ep_total_persisted', 1000, 2000),
]

EMIT_ABSOLUTE = [
    'ep_commit_time_total',
    'ep_io_num_read',
    'ep_io_num_write',
    'ep_io_read_bytes',
    'ep_io_write_bytes',
    'ep_item_begin_failed',
    'ep_item_commit_failed',
    'ep_item_flush_failed',
    'ep_kv_size',
    'ep_oom_errors',
    'ep_pending_ops',
    'ep_queue_size',
    'ep_total_enqueued',
]
EMIT_RATE = [
]


class CouchbaseStats(object):
    def __init__(self):
        self.values = None
        self.collection_time = None
        self.last_values = None
        self.last_collection_time = None

    def get_couchbase_stats(self):
        try:
            stats = subprocess.check_output(['cbc', 'stats'], stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as exc:
            print('CRITICAL - Received error message {0.output!r}'.format(exc))
            sys.exit(2)

        self.values = {}
        for line in stats.decode('utf-8').rstrip('\n').split('\n'):
            key, value = line.split('\t')[1:]
            try:
                value = int(value)
            except ValueError:
                pass
            self.values[key] = value

        self.collection_time = time.time()

    def load_last_run(self):
        try:
            with open(CACHEFILE) as infile:
                last = json.load(infile)
        except IOError:
            return

        self.last_values = last['values']
        self.last_collection_time = last['timestamp']

    def save_current_run(self):
        if self.values is None:
            raise ValueError('No values were loaded')

        with open(CACHEFILE, 'w') as outfile:
            json.dump(
                {
                    'timestamp': self.collection_time,
                    'values': self.values,
                }, outfile)

    def current(self, key):
        return self.values[key]

    def delta(self, key):
        if self.values is None:
            raise ValueError('No values were loaded')

        if self.last_values is None:
            raise ValueError('No last values were loaded')

        return self.values[key] - self.last_values[key]

    def rate(self, key):
        return self.delta(key) / (self.collection_time - self.last_collection_time)

    ### Public

    def check_limits(self):
        warnings = []
        criticals = []

        absolute_template = '"%s" value is %.1f, limit %d.'
        delta_template = '"%s" delta is %d, limit %d.'
        rate_template = '"%s" rate is %.1f/s, limit %d.'

        for limits, method, template in [
            (ABSOLUTE_LIMITS, self.current, absolute_template),
            (DELTA_LIMITS, self.delta, delta_template),
            (RATE_LIMITS, self.rate, rate_template),
        ]:
            for key, warning_threshold, critical_threshold in limits:
                value = method(key)
                if value > critical_threshold:
                    criticals.append(template % (key, value, critical_threshold))
                elif value > warning_threshold:
                    warnings.append(template % (key, value, warning_threshold))

        if criticals:
            output = 'CRITICAL - Couchbase is exceeding critical limits: ' + ' '.join(criticals)
            if warnings:
                output += ' Also exceeding warning limits: ' + ' '.join(warnings)
            self.quit_with_message(2, output)

        if warnings:
            output = 'WARNING - Couchbase is exceeding warning limits:' + ' '.join(warnings)
            self.quit_with_message(1, output)

        self.quit_with_message(0, 'OK - Couchbase is running normally')

    def quit_with_message(self, output_code, message):
        print(message)
        if self.last_values is not None:
            for key in EMIT_RATE:
                print('kwarter.%s.couchbase %d %d' % (key, self.rate(key), self.collection_time))
        for key in EMIT_ABSOLUTE:
            print('kwarter.%s.couchbase %d %d' % (key, self.current(key), self.collection_time))
        sys.exit(output_code)


def main():
    cbs = CouchbaseStats()
    cbs.get_couchbase_stats()
    cbs.load_last_run()
    cbs.save_current_run()

    cbs.check_limits()

if __name__ == '__main__':
    main()
