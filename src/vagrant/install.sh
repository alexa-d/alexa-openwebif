echo "#################################"
echo "instal project dependencies"
sudo yum install -y -d1 libevent-devel unzip zip
	
echo "#################################"
echo "install aws cli"
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
rm -f awscli-bundle.zip

echo "#################################"
echo "set env"
echo export OPENWEBIF_URL=$IN_OPENWEBIF_URL >> /home/vagrant/.bash_profile
echo export AWS_LAMBDA_NAME=$IN_AWS_LAMBDA_NAME >> /home/vagrant/.bash_profile

echo "#################################"
echo "aws cli credentials"
mkdir /home/vagrant/.aws
echo "[default]" >> /home/vagrant/.aws/credentials
echo aws_access_key_id=$AWS_KEY_ID >> /home/vagrant/.aws/credentials
echo aws_secret_access_key=$AWS_KEY_SECRET >> /home/vagrant/.aws/credentials

echo "#################################"
echo "aws cli config"
echo "[default]" >> /home/vagrant/.aws/config
echo region=$AWS_REGION >> /home/vagrant/.aws/config

echo "##################################"
echo "setup compiler ldc2 & dmd"
sudo su vagrant -c "curl -fsS https://dlang.org/install.sh | bash -s ldc"
sudo su vagrant -c "curl -fsS https://dlang.org/install.sh | bash -s dmd"
echo export PATH="/home/vagrant/dlang/dub:/home/vagrant/dlang/dmd-2.072.2/linux/bin64:/home/vagrant/dlang/ldc-1.0.0/bin:${PATH:-}" >> /home/vagrant/.bash_profile
echo export LIBRARY_PATH="/home/vagrant/dlang/dmd-2.072.2/linux/lib64:/home/vagrant/dlang/ldc-1.0.0/lib:${LIBRARY_PATH:-}" >> /home/vagrant/.bash_profile
echo export LD_LIBRARY_PATH="/home/vagrant/dlang/dmd-2.072.2/linux/lib64:/home/vagrant/dlang/ldc-1.0.0/lib:${LD_LIBRARY_PATH:-}" >> /home/vagrant/.bash_profile
sudo su vagrant -c ". ~/.bash_profile"
