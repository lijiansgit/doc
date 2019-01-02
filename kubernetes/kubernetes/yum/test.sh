rpmbuild -ba SPECS/kubernetes-master.spec
/usr/bin/cp RPMS/x86_64/kubernetes-master-1.11.2-1.x86_64.rpm /app/www/mirrors/custom-rpm/7/x86_64/
createrepo -v /app/www/mirrors/custom-rpm/7/x86_64/ --workers=30
