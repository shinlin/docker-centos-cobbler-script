source set-env.sh
yum install -y docker
systemctl start docker
systemctl enable docker

mkdir -p ${PIPEWORK_DIR} 
git clone https://github.com/jpetazzo/pipework.git ${PIPEWORK_DIR}
cp ${PIPEWORK_DIR}/pipework /usr/local/bin/

