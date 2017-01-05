echo "#################################"
echo "instal project dependencies"
sudo yum install -y -d1 libevent-devel unzip
	
echo "#################################"
echo "download compiler"
wget --quiet http://downloads.dlang.org/releases/2.x/2.072.2/dmd-2.072.2-0.fedora.x86_64.rpm

echo "#################################"
echo "install compiler"
sudo yum -y -d1 install dmd-2.072.2-0.fedora.x86_64.rpm

echo "#################################"
echo "install aws cli"
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

echo "#################################"
echo "set env"
echo export OPENWEBIF_URL=$IN_OPENWEBIF_URL >> /home/vagrant/.bash_profile
echo export AWS_LAMBDA_NAME=$IN_AWS_LAMBDA_NAME >> /home/vagrant/.bash_profile
echo export AWS_REGION=$IN_AWS_REGION >> /home/vagrant/.bash_profile