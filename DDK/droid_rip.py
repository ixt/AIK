#!/usr/bin/python3

from itertools import chain
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

from py2neo import Graph, Node, Relationship

class Ripper(object):
    
    def __init__(self,jadx, raccoon, app_dir=False, host='neo4j'):
        if not app_dir:
            self.app_dir = '/'.join([os.getcwd(),'apps'])
        else:
            self.app_dir = app_dir
        self.jadx_path = jadx
        self.raccoon_path = raccoon

        self.neo = Graph(host=host, bolt=False)
    
    def collate(self,entities):
        out = {}
        for e in entities:
            chunks = e.split('.')
            if len(chunks) > 1 and 1 not in [len(c) for c in chunks]:
                org_chunks = []
                for c in chunks:
                    org_chunks.append(c)
                    if len(c) > 3:
                        break
                org = '.'.join(org_chunks[::-1])
                if out.get(org,False):
                    out[org].append(e)
                else:
                    out[org] = [e]
        return out
            
    def rip(self,apkfile):
        apk_path = os.path.dirname(apkfile)
        apk = '.'.join(apkfile.split('/')[-1].split('.')[0:-1])
        output_dir = '/'.join(['/root',apk])
        subprocess.call([self.jadx_path,'-d',output_dir,apkfile])
        try:
            manifest = ET.parse('/'.join([output_dir,'AndroidManifest.xml']))
        except:
            return False
        
        package = manifest._root.get('package')

        get_names = lambda t: [i.get('{http://schemas.android.com/apk/res/android}name') for i in manifest.iter(t)]
        interesting = lambda t: list(filter(lambda n: not n.startswith(package),get_names(t)))

        activities = interesting('activity')
        services = interesting('service')
        permissions = get_names('uses-permission')
        
        finder = ' '.join(['grep -PIrho "(?<=^package\s)[^;]*"',output_dir,'| sort | uniq'])
        proc = subprocess.run(['bash','-c',finder],stdout=subprocess.PIPE,universal_newlines=True)
        all_the_packages = proc.stdout.split('\n')[:-1]
        dull = [package, 'android.', 'java.', 'javax.']
        not_boring = lambda p: len(p.split('.')[0]) > 1 and not any([p.startswith(d) for d in dull])
        packages = list(filter(not_boring,all_the_packages))

        orgs_activities = self.collate(activities)
        orgs_services = self.collate(services)
        orgs_packages = self.collate(packages)

        return {'app':package, 'activities':orgs_activities, 'services':orgs_services, 'packages':orgs_packages, 'permissions':permissions}

    def info(self,package):
        proc = subprocess.run(['java','-jar',self.raccoon_path,'-gpa-details',package], stdout=subprocess.PIPE,universal_newlines=True)

        regexes = {'title':r'(?<=title:\s").*(?=")', 'creator':r'(?<=creator:\s").*(?=")', 'description':r'(?<=descriptionHtml:\s").*(?=")',
            'email':r'(?<=developerEmail:\s").*(?=")', 'website':r'(?<=developerWebsite:\s").*(?=")'}
        
        out = {'name':package}
        
        for k,r in regexes.items():
            match = re.findall(r, proc.stdout)
            if match:
                out[k] = match[0]

        return out

    def push(self,data, info=None):
        tx = self.neo.begin()
        if info:
            app = Node('App', **info)
        else:
            app = Node('App', name=data['app'])
        tx.merge(app)
        
        sources = {src:Node('PackageSource',name=src) for src in data['packages'].keys()}
        for src in sources.values():
            tx.merge(src)
            
        for src in sources.keys():
            this_source = sources[src]
            packages = [Node('Package', name=pkg) for pkg in data['packages'][src]]
            for p in packages:
                tx.merge(p)
                tx.merge(Relationship(app, 'CONTAINS', p))
                tx.merge(Relationship(this_source, 'PROVIDES', p))
                
        for src in data['activities'].keys():
            this_source = sources.get(src,False)
            if this_source:
                activities = [Node('Activity', name=act) for act in data['activities'][src]]
                for a in activities:
                    tx.merge(a)
                    tx.merge(Relationship(app, 'CONTAINS', a))
                    tx.merge(Relationship(this_source, 'PROVIDES', a))
                
        for src in data['services'].keys():
             this_source = sources.get(src,False)
             if this_source:
                services = [Node('Service', name=srv) for srv in data['services'][src]]
                for s in services:
                    tx.merge(s)
                    tx.merge(Relationship(app, 'CONTAINS', s))
                    tx.merge(Relationship(this_source, 'PROVIDES', s))
                
        permissions = [Node('Permission', name=perm) for perm in data['permissions']]
        for p in permissions:
            tx.merge(p)
            tx.merge(Relationship(app, 'USES', p))
            
        tx.commit()
                
if __name__ == "__main__":
    
    path = sys.argv[1]
    
    jadx = '/tools/bin/jadx'
    raccoon = '/tools/raccoon-4.2.1.jar'
    app_dir = '/root/apps'
    
    rip = Ripper(jadx,raccoon,app_dir=app_dir)
                
    for apk in chain(*[['/'.join([p[0],f]) for f in p[-1] if f.endswith('.apk')] for p in os.walk(path)]):
        print("RIPPING: "+apk)
        app_data = rip.rip(apk)
        if app_data:
            app_info = rip.info(app_data['app'])
            print("PUSHING: "+apk)
            rip.push(app_data, info=app_info)
            