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
echo export AWS_LAMBDA_NAME=$IN_AWS_LAMBDA_NAME >> /home/vagrant/.bash_profile
echo export AWS_DYNAMODB_KEY_ID=$IN_AWS_DYNAMODB_KEY_ID >> /home/vagrant/.bash_profile
echo export AWS_DYNAMODB_KEY_SECRET=$IN_AWS_DYNAMODB_KEY_SECRET >> /home/vagrant/.bash_profile
echo export AWS_DYNAMODB_REGION=$IN_AWS_DYNAMODB_REGION >> /home/vagrant/.bash_profile
echo export OPENWEBIF_TABLENAME=$IN_OPENWEBIF_TABLENAME >> /home/vagrant/.bash_profile

echo "#################################"
echo "aws cli credentials"
mkdir /home/vagrant/.aws
echo "[default]" >> /home/vagrant/.aws/credentials
echo aws_access_key_id=$IN_AWS_KEY_ID >> /home/vagrant/.aws/credentials
echo aws_secret_access_key=$IN_AWS_KEY_SECRET >> /home/vagrant/.aws/credentials

echo "#################################"
echo "aws cli config"
echo "[default]" >> /home/vagrant/.aws/config
echo region=$IN_AWS_REGION >> /home/vagrant/.aws/config

echo "##################################"
echo "setup compiler ldc2 & dmd"
sudo su vagrant -c "curl -fsS https://dlang.org/install.sh | bash -s ldc"
sudo su vagrant -c "curl -fsS https://dlang.org/install.sh | bash -s dmd"
sudo su vagrant -c 'echo export PATH="/home/vagrant/dlang/dub:/home/vagrant/dlang/dmd-2.073.0/linux/bin64:/home/vagrant/dlang/ldc-1.1.0/bin:\$PATH" >> /home/vagrant/.bash_profile'
sudo su vagrant -c 'echo export LIBRARY_PATH="/home/vagrant/dlang/dmd-2.073.0/linux/lib64:/home/vagrant/dlang/ldc-1.1.0/lib:\$LIBRARY_PATH" >> /home/vagrant/.bash_profile'
sudo su vagrant -c 'echo export LD_LIBRARY_PATH="/home/vagrant/dlang/dmd-2.073.0/linux/lib64:/home/vagrant/dlang/ldc-1.1.0/lib:\$LD_LIBRARY_PATH" >> /home/vagrant/.bash_profile'
sudo su vagrant -c ". ~/.bash_profile"
