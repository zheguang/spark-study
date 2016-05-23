#!/usr/bin/python
import sys
import requests

# python3.5 perftool.py http://ec2-54-186-116-126.us-west-2.compute.amazonaws.com:18080/api/v1/applications/application_1463950319954_0001/1/jobs
# When searching down the path, [app-id] is actually [app-id]/[attempt-id] when running in Yarn. http://spark.apache.org/docs/latest/monitoring.html

class RestHandle:
    port = '18080'
    root = '/api/v1/applications'
    proxies = {
            'http'  : 'socks5://localhost:8157',
            'https' : 'socks5://localhost:8157'
    }

    def __init__(self, server):
        self.server = server

    def endpoint(self):
        return 'http://{}:18080:{}'.format(self.server, self.root)

    def url(self, *nodes):
        return '{}/{}'.format(self.endpoint(), '/'.join(nodes))

    def get(self, resource):
        resp = requests.get(self.url(resource), proxies=proxies)
        if resp.status_code != 200:
            raise RuntimeError('Error: {}'.format(resp))
        return resp.json()


#class Parser:
#    app_attempt_id = '1' # The app-id always has an associated attempt-id on YARN (http://spark.apache.org/docs/latest/monitoring.html).
#
#    def __init__(self, rest_handle):
#        self.handle = rest_handle
#
#    def parse(self, app_id):
#        stages_json = self.handle.get(str(app_id), self.app_attempt_id, 'stages')
#        jobs_json = self.handle.get(str(app_id), self.app_attempt_id, 'jobs')
#
#        stages = map(lambda x: parse, stages_json
#
#
#
#class Application:
#    def __init__(self, app_id, jobs):
#        self.app_id = app_id
#        self.jobs = jobs
#
#
#class Job:
#    def __init__(self, job_id, start_time, end_time, stages):
#        self.job_id = job_id
#        self.start_time = start_time
#        self.end_time = end_time
#        self.stages = stages
#
#
#class Stage:
#    def __init__(self, stage_id, tasks):
#        self.stage_id = stage_id
#        self.tasks = tasks
#
#
#class Task:
#    def __init__(self, task_id, start_time):
#        self.task_id = task_id
#        self.start_time = start_time
#

def main(args):
    assert len(args) > 1
    endpoint = str(args[1])
    print('[info] endpoint: {}'.format(endpoint))
    resp = requests.get(endpoint, proxies=proxies)
    if resp.status_code != 200:
        raise RuntimeError('Error: {}, {}'.format(resp.status_code, resp))
    else:
        print(resp.json())


if __name__ == '__main__':
    main(sys.argv)
