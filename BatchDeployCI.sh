environment=$1
currentBuild_number=`cat .version`
mkdir work
mkdir work/config
cp -r scripts work/
    echo "${environment}"
    cp -r config/${environment}/* work/config/

cd work
zip -rq "../Batch-${currentBuild_number}.zip" *
cd ..
rm -rf work
mkdir work
mkdir work/config
cp -r scripts work/
echo "${environment}"
cp -r config/${environment}/* work/config/

cd work
zip -rq "../Batch-${environment}-${currentBuild_number}.zip" *
cd ..
rm -rf work
