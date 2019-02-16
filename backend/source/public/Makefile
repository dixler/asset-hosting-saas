all: deleteAsset.zip retrieveAsset.zip createAsset.zip getAssets.zip getUser.zip login.zip login.zip logout.zip

createAsset.zip: createAsset.py utils.py environment.zip
	cp environment.zip $@; zip -g $@ createAsset.py utils.py

retrieveAsset.zip: retrieveAsset.py utils.py environment.zip
	cp environment.zip $@; zip -g $@ retrieveAsset.py utils.py

login.zip: login.py utils.py environment.zip
	cp environment.zip $@; zip -g $@ login.py utils.py

deleteAsset.zip: deleteAsset.py utils.py environment.zip
	cp environment.zip $@; zip -g $@ deleteAsset.py utils.py

getAssets.zip: getAssets.py utils.py environment.zip
	cp environment.zip $@; zip -g $@ getAssets.py utils.py

getUser.zip: getUser.py utils.py environment.zip
	cp environment.zip $@; zip -g $@ getUser.py utils.py

logout.zip: logout.py utils.py environment.zip
	cp environment.zip $@; zip -g $@ logout.py utils.py

environment.zip:
	cd environment/lib/python3.7/site-packages/; zip -r9 ../../../../$@ .;

clean:
	rm -rf retrieveAsset.zip deleteAsset.zip createAsset.zip getAssets.zip getUser.zip login.zip login.zip logout.zip
