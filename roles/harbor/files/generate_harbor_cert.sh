cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes harbor-csr.json cfssljson -bare harbor
# 拷贝到使用证书的roles下
root_dir=$(pwd |sed 's#ssl/harbor##')
apiserver_cert_dir=$root_dir/roles/master/files/harbor_cert
harbor_cert_dir=$root_dir/roles/harbor/files/harbor_cert
mkdir -p $harbor_cert_dir $apiserver_cert_dir
for dir in $apiserver_cert_dir $harbor_cert_dir; do
   cp -rf ca.pem server.pem server-key.pem $dir
done