#/bin/bash

export AGIGA=$1
export WORK=$2
export THREADS=30
export SCRIPTS=$ABS/dataset
export SPLITS=$ABS/dataset
export UNK=5

echo "Step 1: Construct the title-article pairs from gigaword"
mkdir -p $WORK
find $AGIGA/???/*.gz | parallel --gnu --progress -j $THREADS python2.7 $SCRIPTS/process_agiga.py \{\} ${WORK}/


echo "Step 2: Compile the data into train/dev/test."
cd $WORK
cat $SPLITS/train.splits | xargs cat > train.data.txt
cat $SPLITS/valid.splits | xargs cat > valid.data.txt
cat $SPLITS/test.splits  | xargs cat > test.data.txt


echo "Step 3: Basic filtering on train/dev."
python2.7 $SCRIPTS/filter.py train.data.txt > train.data.filter.txt
python2.7 $SCRIPTS/filter.py valid.data.txt > valid.data.filter.txt


echo "Step 4: Compile dictionary."
python2.7 $SCRIPTS/make_dict.py train.data.filter.txt train $UNK


echo "Step 5: Construct title-article files."
python2.7 $SCRIPTS/pull.py trg_lc train.title.dict   < train.data.filter.txt > train.title.txt
python2.7 $SCRIPTS/pull.py src_lc train.article.dict < train.data.filter.txt > train.article.txt

python2.7 $SCRIPTS/pull.py trg_lc train.title.dict   < valid.data.txt > valid.title.txt
python2.7 $SCRIPTS/pull.py src_lc train.article.dict < valid.data.txt > valid.article.txt

python2.7 $SCRIPTS/pull.py trg_lc train.title.dict   < valid.data.filter.txt > valid.title.filter.txt
python2.7 $SCRIPTS/pull.py src_lc train.article.dict < valid.data.filter.txt > valid.article.filter.txt

python2.7 $SCRIPTS/pull.py trg_lc train.title.dict   < test.data.txt > test.title.txt
python2.7 $SCRIPTS/pull.py src_lc train.article.dict < test.data.txt > test.article.txt


echo "Step 6: Constructing torch data files."
cd ..
bash $ABS/prep_torch_data.sh $WORK
