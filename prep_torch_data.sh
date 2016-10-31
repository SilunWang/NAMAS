#/bin/bash

COUNT=5
WINDOW=5

DATA_DIR=$1
OUT_DIR=$1/processed
SCRIPTS=$ABS/summary

export LUA_PATH="$LUA_PATH;$ABS/?.lua"

mkdir -p $OUT_DIR

th $SCRIPTS/build_dict.lua -inf $DATA_DIR/train.article.dict -outf $OUT_DIR/train.article.dict.torch
th $SCRIPTS/build_dict.lua -inf $DATA_DIR/train.title.dict   -outf $OUT_DIR/train.title.dict.torch

echo "-- Creating data directories."
mkdir -p $OUT_DIR/train/title
mkdir -p $OUT_DIR/train/article

mkdir -p $OUT_DIR/valid/title
mkdir -p $OUT_DIR/valid/article

cp $OUT_DIR/train.title.dict.torch $OUT_DIR/train/title/dict
cp $OUT_DIR/train.article.dict.torch $OUT_DIR/train/article/dict


echo "-- Build the matrices"

# Share the dictionary.
th $SCRIPTS/build.lua -inArticleDictionary $OUT_DIR/train.article.dict.torch -inTitleDictionary $OUT_DIR/train.title.dict.torch -inTitleFile $DATA_DIR/valid.title.txt -outTitleDirectory $OUT_DIR/valid/title/ -inArticleFile $DATA_DIR/valid.article.txt -outArticleDirectory $OUT_DIR/valid/article/ -window $WINDOW

th $SCRIPTS/build.lua -inArticleDictionary $OUT_DIR/train.article.dict.torch -inTitleDictionary $OUT_DIR/train.title.dict.torch -inTitleFile $DATA_DIR/train.title.txt  -outTitleDirectory $OUT_DIR/train/title/ -inArticleFile $DATA_DIR/train.article.txt -outArticleDirectory $OUT_DIR/train/article/ -window $WINDOW
