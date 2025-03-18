environment=$1
currentBuild_number=$2
mkdir work
mkdir work/config
cp -r scripts work/
    echo "${environment}"
    cp -r config/${environment}/* work/config/

cd work
zip -rq "../Batch-${currentBuild_number}.zip" *
cd ..
rm -rf work
